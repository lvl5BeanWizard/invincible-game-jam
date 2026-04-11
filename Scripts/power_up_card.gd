class_name PowerupCard
extends Node2D

var power_name
var power_desc

@export var powerup: Powerup

@onready var button = $Button
@onready var name_txt = $Button/Name
@onready var desc_txt = $Button/Descr
@onready var image = $Button/Image

@onready var green_texture = preload("res://Textures/green_card_texture.tres")
@onready var red_texture = preload("res://Textures/red_card_texture.tres")
@onready var orange_texture = preload("res://Textures/orange_card_texture.tres")

signal powerup_picked(selected_powerup: Powerup)

# Called when the node enters the scene tree for the first time.
func _ready():
	name_txt.text = powerup.name
	desc_txt.text = powerup.desc
	image.texture = powerup.image_texture
	
	match powerup.type:
		0:
			button.texture_normal = red_texture
		1:
			button.texture_normal = green_texture
		2:
			button.texture_normal = orange_texture
		_:
			button.texture_normal = green_texture
			

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_button_pressed():
	#on click, send out a signal saying we picked this one
	powerup_picked.emit(powerup)

func deselect():
	$SelectedRect.visible = false

func select():
	$SelectedRect.visible = true
	
func get_powerup():
	return powerup
