extends Node3D

@onready var character = $Character
@onready var minimap_cam = $MarginContainer/PanelContainer/SubViewportContainer/SubViewport/Camera3D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	minimap_cam.global_position.x = character.global_position.x
	minimap_cam.global_position.z = character.global_position.z
