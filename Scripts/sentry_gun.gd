extends Node3D

@onready var shootybit = $ShootyBitMesh
@onready var shoot_cooldown = $ShootCooldown

@export var rot_speed = .015
@export var damage = 1

var shooting = false
var target

@onready var bullet = preload("res://Scenes/sentry_bullet.tscn")

func _ready():
	pass

func _process(delta: float) -> void:
	if not shooting:
		shootybit.rotation.y += rot_speed
	else:
		shootybit.look_at(target.position)
		shootybit.rotation_degrees.x += 20 #dunno why, but she wants to aim up for some reason
		#shootybit.rotation.z += 0
		shootybit.rotation_degrees.y += 180
		if target == null:
			#we got him
			shoot_cooldown.stop()
			shooting = false
			pick_new_target()

func _on_shoot_cooldown_timeout() -> void:
	if target != null:
		#spawn bullet
		var b = bullet.instantiate()
		get_tree().root.add_child(b)
		b.global_transform = $ShootyBitMesh/BulletSpawnPoint.global_transform
		b.set_str(damage)
	
func pick_new_target():
	shooting = false
	target = null
	var bodies = $Area3D.get_overlapping_bodies()
	for b in bodies:
		if b.is_in_group("Enemy"):
			target = b
			shooting = true
			shoot_cooldown.start()

func _on_area_3d_area_entered(area):
	if area.is_in_group("Enemy"):
		target = area.get_parent()
		shooting = true
		shoot_cooldown.start()

func _on_area_3d_area_exited(area):
	if area.get_parent() == target:
		pick_new_target()

func set_strength(str: int):
	damage = str
