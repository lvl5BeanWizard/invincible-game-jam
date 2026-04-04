class_name PowerupCard
extends Node2D

var power_name
var power_desc

@export var powerup: Powerup

@onready var name_txt = $TextureRect/Name
@onready var desc_txt = $TextureRect/Descr
@onready var image = $TextureRect/Image

# Called when the node enters the scene tree for the first time.
func _ready():
	name_txt.text = powerup.name
	desc_txt.text = powerup.desc
	image.texture = powerup.texture
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
