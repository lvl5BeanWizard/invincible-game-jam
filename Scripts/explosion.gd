extends Node3D

var str: int = 3

# Called when the node enters the scene tree for the first time.
func _ready():
	await get_tree().create_timer(0.5).timeout
	queue_free()

func set_str(new_str: int):
	str = new_str

func _on_area_3d_body_entered(body):
	if body.is_in_group("Enemy"):
		body.get_parent()._take_damage(str)
