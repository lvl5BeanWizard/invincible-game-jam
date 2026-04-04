class_name PowerupCard
extends Node2D

var power_name
var power_desc

@export var powerup: Powerup

@onready var name_txt = $Button/Name
@onready var desc_txt = $Button/Descr
@onready var image = $Button/Image

signal powerup_picked(selected_powerup: Powerup)

# Called when the node enters the scene tree for the first time.
func _ready():
	name_txt.text = powerup.name
	desc_txt.text = powerup.desc
	image.texture = powerup.texture

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_button_pressed():
	#on click, send out a signal saying we picked this one
	powerup_picked.emit(powerup)
