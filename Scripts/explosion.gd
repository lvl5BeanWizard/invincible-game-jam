extends Node3D

var str: int = 3

@onready var smoke = $Smoke
@onready var fire = $Fire
@onready var debris = $Debris


# Called when the node enters the scene tree for the first time.
func _ready():
	debris.emitting = true
	smoke.emitting = true
	fire.emitting = true
	$ExplosionSound.play()
	
	#turn off the damage after 3/4s of a second
	await get_tree().create_timer(0.75).timeout
	$Area3D.monitorable = false
	
	#and delete itself after a full 2 seconds
	await get_tree().create_timer(1.25).timeout
	queue_free()

func set_str(new_str: int):
	str = new_str

func _on_area_3d_body_entered(body):
	if body.is_in_group("Enemy"):
		body.get_parent()._take_damage(str)
