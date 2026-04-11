extends Node3D

@export var strength: int = 3
@onready var explosion = preload("res://Scenes/explosion.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$Path3D/PathFollow3D.progress_ratio += .01
	$Path3D/PathFollow3D/MeshInstance3D.rotate_z(.2)
	if $Path3D/PathFollow3D.progress_ratio > .8:
		queue_free()

func set_str(new_strength: int):
	strength = new_strength

func _on_rocket_body_entered(body):
	#spawn an explosion
	var e = explosion.instantiate()
	e.set_str(strength)
	e.global_transform = $Path3D/PathFollow3D/MeshInstance3D.global_transform
	get_tree().current_scene.add_child(e)
	
	#clean up rocket
	queue_free()
