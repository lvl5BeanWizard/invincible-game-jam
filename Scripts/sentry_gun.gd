extends Node3D

@onready var shootybit = $ShootyBitMesh
@onready var shoot_cooldown = $ShootCooldown

@export var rot_speed = .02
@export var damage = 1

var shooting = false
var target

func _ready():
	pass

func _process(delta: float) -> void:
	if not shooting:
		shootybit.rotation.y += rot_speed
	else:
		shootybit.look_at(target)
		if target == null:
			#we got him
			shooting = false
	
func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("Enemy"):
		shooting = true
		target = body
		shoot_cooldown.start()
		
func _on_shoot_cooldown_timeout() -> void:
	#TODO spawn bullet
	pass
	
func pick_new_target():
	shooting = false
	target = null
	var bodies = $Area3D.get_overlapping_bodies()
	for b in bodies:
		if b.is_in_group("Enemy"):
			target = b
			shooting = true
