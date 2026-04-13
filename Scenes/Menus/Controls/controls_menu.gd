extends Control

@onready var return_button: Button = %ReturnButton
@onready var AllButtons : Array[Button] = [return_button]

@onready var _selected_button : Button = return_button
var Selected_Index = 1
var New_Selected_Index = 1

@onready var MenuSounds : AudioStreamPlayer2D = %MenuSounds
@onready var BGM : AudioStreamPlayer2D = %BGM

@onready var ChangeSelectionSound = preload("res://Sounds/Menu Sounds/ChangeSelection.ogg")
@onready var LoserSound = preload("res://Sounds/Menu Sounds/Loser.ogg")


func _ready():
	return_button.connect("ClickedButton",ActivateButton)
	MenuSounds.stream = ChangeSelectionSound
	_selected_button.grab_focus()

func _process(_elta):
	if Input.is_action_just_pressed("menu_quit"):
		get_tree().change_scene_to_file("res://Scenes/Menus/MainMenu/MainMenu.tscn")
	
	if Input.is_action_just_pressed("menu_accept"):
		ActivateButton(_selected_button)


func ActivateButton(PassedButton : Button):
	match PassedButton.text:
		"Return":
			get_tree().change_scene_to_file("res://Scenes/Menus/MainMenu/MainMenu.tscn")
	MenuSounds.play()
