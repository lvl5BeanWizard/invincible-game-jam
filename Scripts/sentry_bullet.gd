extends Node3D

@export var strength: int = 3
var speed = 50
var velocity = Vector3.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	global_translate(-global_transform.basis.z * speed * delta)

func set_str(new_strength: int):
	strength = new_strength

func _on_bullet_body_entered(body):
	if body.is_in_group("Enemy"):
		body.get_parent()._take_damage(strength)
		
	queue_free()
