## A first-person character controller with camera controls, movement, sprinting, and jumping.
## Requires a CameraPivot (Node3D) and Camera3D as children, and a character mesh as a child node.
extends CharacterBody3D

enum CameraMode {
	FIRST_PERSON,
	THIRD_PERSON
}

## Node References
## -----------------------------------------------------------------------------
## These nodes must exist in the scene tree for the controller to work properly.

@onready var camera_pivot: Node3D = %CameraPivot
@onready var camera_3d: Camera3D = %Camera3D
@onready var spring_arm: SpringArm3D = camera_pivot.get_node("SpringArm3D")
@onready var character: Node3D = $character
@onready var arm_laser: Node3D = $character/ArmLaser

## Movement Settings
## -----------------------------------------------------------------------------
## Configure the character's movement speed and jump behavior.

@export_group("Movement")
@export_range(0.1, 20.0, 0.1, "or_greater") var speed: float = 5.0
## Speed when walking. Should be lower than normal speed.
@export_range(0.1, 10.0, 0.1, "or_greater") var walk_speed: float = 2.5
## Speed multiplier when sprinting. Should be higher than normal speed.
@export_range(0.1, 30.0, 0.1, "or_greater") var sprint_speed: float = 8.0
## Vertical velocity applied when jumping.
@export_range(1.0, 20.0, 0.1) var jump_velocity: float = 4.5
@export var can_walk: bool = true

## Camera Settings
## -----------------------------------------------------------------------------
## Adjust camera sensitivity and rotation limits.

@export_group("Camera")
## Mouse sensitivity for camera rotation. Higher values = faster rotation.
@export_range(0.0, 1.0, 0.001) var mouse_sensitivity: float = 0.005
## Enable controller support for camera look.
@export var controller_support: bool = true
## Controller stick sensitivity for camera rotation.
@export_range(0.1, 10.0, 0.1) var controller_sensitivity: float = 2.0
## Maximum vertical camera tilt angle in radians (prevents over-rotation).
@export_range(0.0, 1.57, 0.01) var tilt_limit: float = deg_to_rad(75)
## Speed at which the character mesh rotates to face movement direction.
@export_range(0.1, 50.0, 0.1) var rotation_speed: float = 10.0
## Camera mode: FIRST_PERSON or THIRD_PERSON.
@export var camera_mode: CameraMode = CameraMode.THIRD_PERSON:
	set(value):
		camera_mode = value
		if is_node_ready():
			_update_camera_mode()
## Camera distance (SpringArm length) for third-person mode.
@export_range(0.0, 10.0, 0.1) var camera_distance: float = 3.5
## Speed at which the camera transitions between modes.
@export_range(1.0, 20.0, 0.1) var camera_transition_speed: float = 8.0
## Allow switching between camera modes with V key.
@export var allow_camera_mode_switch: bool = false

var input_dir: Vector2 = Vector2.ZERO
var input_strength: float = 0.0
var direction: Vector3 = Vector3.ZERO
var is_sprinting: bool = false
var is_walking: bool = false
var is_jumping: bool = false

# Freeze the character. It may be useful when you want to pause the character.
var frozen: bool = false

var target_camera_distance: float = 3.5
var is_transitioning_camera: bool = false

#begin mad science
@onready var powerup_handler = $PowerUpHandler
var powerups = []

signal shoot_arm_laser(aim_node)
signal stop_arm_laser
@onready var laser_aim_node = $CameraPivot/SpringArm3D/Camera3D/LaserAimNode

var has_rockets = false
var rocket_qty = 3
var rocket_str = 3
@onready var rocket_launcher = $character/GeneralSkeleton/BoneAttachment3D/RocketLauncher

var has_jetpack = false
@onready var jetpack = $character/GeneralSkeleton/BoneAttachment3D/Jetpack

@onready var server = get_node("/root/TestLevel/Server")

#end mad science

func _ready() -> void:
	powerup_handler.got_powerup.connect(_on_got_powerup)
	
	## Captures the mouse cursor for first-person camera control.
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	target_camera_distance = 0.0 if camera_mode == CameraMode.FIRST_PERSON else camera_distance
	spring_arm.spring_length = target_camera_distance
	if character:
		character.visible = camera_mode == CameraMode.THIRD_PERSON

func _physics_process(delta: float) -> void:
	_handle_gravity_and_jump(delta)
	_handle_camera_transition(delta)
	_handle_controller_camera(delta)
	_handle_shooting(delta)
	if has_rockets:
		_handle_rockets(delta)
	
	if powerup_handler.visible:
		frozen = true
	
	if frozen:
		handle_frozen_movement()
		move_and_slide()
		return

	_handle_movement_input()
	if camera_mode == CameraMode.THIRD_PERSON:
		_handle_character_rotation(delta)
	_apply_movement()
	move_and_slide()

func handle_frozen_movement() -> void:
	velocity.x = 0.0
	velocity.z = 0.0
	input_dir = Vector2.ZERO
	is_sprinting = false
	is_walking = false

## Handles gravity application and jump mechanics.
func _handle_gravity_and_jump(delta: float) -> void:
	if not has_jetpack:
		if not is_on_floor():
			velocity += get_gravity() * delta
			is_jumping = velocity.y > 0
		else:
			is_jumping = false

		if not frozen and Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = jump_velocity
			is_jumping = true
	else:
		if Input.is_action_pressed("jump"):
			velocity.y = jump_velocity
			jetpack.emit_smoke(true)
		else:
			velocity += get_gravity() * delta
			jetpack.emit_smoke(false)

## Processes movement input and calculates movement direction relative to camera.
func _handle_movement_input() -> void:
	input_dir = Input.get_vector("left", "right", "forward", "backward")
	input_strength = minf(input_dir.length(), 1.0)
	
	var camera_basis = Transform3D(Basis(Vector3.UP, camera_pivot.rotation.y), Vector3.ZERO).basis
	direction = (camera_basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

## Rotates the character mesh to face the movement direction smoothly.
func _handle_character_rotation(delta: float) -> void:
	if camera_mode == CameraMode.FIRST_PERSON:
		return
	character.rotation.y = lerp_angle(character.rotation.y, camera_pivot.rotation.y + PI, rotation_speed * delta)

## Handles controller stick input for camera rotation.
func _handle_controller_camera(delta: float) -> void:
	if not controller_support or frozen:
		return
	if not InputMap.has_action("look_left") or not InputMap.has_action("look_right") or not InputMap.has_action("look_up") or not InputMap.has_action("look_down"):
		return
	var look_dir = Input.get_vector("look_left", "look_right", "look_up", "look_down")
	if look_dir != Vector2.ZERO:
		camera_pivot.rotation.y -= look_dir.x * controller_sensitivity * delta
		camera_pivot.rotation.x += look_dir.y * controller_sensitivity * delta
		camera_pivot.rotation.x = clampf(camera_pivot.rotation.x, -tilt_limit, tilt_limit)

## Handles smooth camera transition between modes.
func _handle_camera_transition(delta: float) -> void:
	spring_arm.spring_length = lerp(spring_arm.spring_length, target_camera_distance, camera_transition_speed * delta)
	
	if character and camera_distance > 0.0:
		var transition_progress = spring_arm.spring_length / camera_distance
		var visibility_threshold = 0.3
		character.visible = transition_progress > visibility_threshold
	elif character:
		character.visible = camera_mode == CameraMode.THIRD_PERSON

## Updates camera mode (sets target for smooth transition).
func _update_camera_mode() -> void:
	if camera_mode == CameraMode.FIRST_PERSON:
		target_camera_distance = 0.0
	else:
		target_camera_distance = camera_distance

## Applies horizontal movement velocity based on input and sprint/walk state.
func _apply_movement() -> void:
	var is_moving = input_dir != Vector2.ZERO and is_on_floor()
	is_sprinting = Input.is_action_pressed("sprint") and is_moving and not Input.is_action_pressed("walk")
	is_walking = Input.is_action_pressed("walk") and is_moving and not Input.is_action_pressed("sprint") and can_walk
	
	var current_speed: float
	if is_sprinting:
		current_speed = sprint_speed
	elif is_walking and can_walk:
		current_speed = walk_speed
	else:
		current_speed = speed
	
	if direction:
		velocity.x = direction.x * current_speed * input_strength
		velocity.z = direction.z * current_speed * input_strength
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)



## Handles mouse input for camera rotation with tilt limits.
func _unhandled_input(event: InputEvent) -> void:

	if frozen:
		return

	if event is InputEventKey and event.physical_keycode == KEY_ESCAPE:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	if event is InputEventMouseMotion:
		camera_pivot.rotation.x -= event.relative.y * mouse_sensitivity
		camera_pivot.rotation.x = clampf(camera_pivot.rotation.x, -tilt_limit, tilt_limit)
		camera_pivot.rotation.y += -event.relative.x * mouse_sensitivity

func _input(event: InputEvent) -> void:
	if InputMap.has_action("camera_mode_switch") and event.is_action_pressed("camera_mode_switch") and allow_camera_mode_switch:
		camera_mode = CameraMode.THIRD_PERSON if camera_mode == CameraMode.FIRST_PERSON else CameraMode.FIRST_PERSON
		_update_camera_mode()
		
		
##mad science cont.

##handles shooting our arm laser
func _handle_shooting(delta: float) -> void:
	if Input.is_action_just_pressed("shoot"):
		shoot_arm_laser.emit(laser_aim_node)
	elif Input.is_action_just_released("shoot"):
		stop_arm_laser.emit()

func _handle_rockets(delta):
	if Input.is_action_just_pressed("Rockets"):
		rocket_launcher._spawn_rockets(rocket_qty, rocket_str)

func _on_got_powerup(powerup: Powerup):
	print(powerup.name)
	#this is gross, but hey it's a game jam
	if powerup.name == "Rocket Launcher":
		has_rockets = true
		rocket_launcher.visible = true
	elif powerup.name == "Jetpack":
		has_jetpack = true
		jetpack.visible = true
	elif powerup.name == "Server Heals":
		server.set_heal_over_time(2)
	frozen = false
	
