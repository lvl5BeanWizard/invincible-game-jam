extends Node3D

@onready var character = get_parent().get_parent()
@onready var camera = get_viewport().get_camera_3d()

var shooting: bool = false
var laser_damage = 0.2

func _ready():
	character.shoot_arm_laser.connect(_on_shoot)
	character.stop_arm_laser.connect(_on_stop_shoot)

func _process(delta):
	
	if shooting:
		$RayCast3D.enabled = true
		$Laser.visible = true
		$Area3D/CollisionShape3D.disabled = false
		if $RayCast3D.is_colliding():
			var collision_point = $RayCast3D.get_collision_point()
			var distance = $RayCast3D.global_position.distance_to(collision_point)
			
			$Laser.scale.y = distance
			$Laser.position.z = distance/2
			
			$Area3D/CollisionShape3D.scale.y = distance
			$Area3D/CollisionShape3D.position.z = distance/2
			
			var collider = $RayCast3D.get_collider()
			if collider.is_in_group("Enemy"):
				collider.get_parent()._take_damage(laser_damage)
				
	else:
		$RayCast3D.enabled = false
		$Laser.visible = false
		$Area3D/CollisionShape3D.disabled = true

func _on_shoot():
	shooting = true
	
func _on_stop_shoot():
	shooting = false

func get_laser_damage():
	return laser_damage
	
func set_laser_damage(new_laser_damage):
	laser_damage = new_laser_damage
