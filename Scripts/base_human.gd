extends Node3D

@onready var server_loc = get_node("/root/TestLevel/Server").position

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position = position.move_toward(server_loc, 2 * delta)
