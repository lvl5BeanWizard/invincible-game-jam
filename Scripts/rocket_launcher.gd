extends Node3D

@onready var rocket = preload("res://Scenes/rocket.tscn")

#lil rng never hurt no one
@onready var rand = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _spawn_rockets(qty: int, strength: int):
	for q in range(qty):
		var r = rocket.instantiate()
		r.set_str(strength)
		r.global_transform = global_transform
		var rand_rot = rand.randf_range(-0.3,0.3)
		r.rotation.y += rand_rot
		get_tree().current_scene.add_child(r)
		#sleep for a half second before adding another
		await get_tree().create_timer(0.5).timeout
