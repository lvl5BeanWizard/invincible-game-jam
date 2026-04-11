extends Control

@onready var PlayButton = %PlayButton
@onready var SettingsButton = %SettingButton
@onready var QuitButton = %QuitButton

@onready var SelectedColor : Color = Color(255,0,0,255)
@onready var DefaultColor : Color = Color(0,186,0,255)

@onready var _selected_button : Button = PlayButton
var curr_Selected = 1
var new_Selected 

@onready var MenuSounds : AudioStreamPlayer2D = %MenuSounds
@onready var BGM : AudioStreamPlayer2D = %BGM

@onready var ChangeSelectionSound = preload("res://Sounds/Menu Sounds/ChangeSelection.ogg")
@onready var LoserSound = preload("res://Sounds/Menu Sounds/Loser.ogg")

func _ready():
	_selected_button.add_theme_color_override("font_color", SelectedColor)
	MenuSounds.stream = ChangeSelectionSound
	
func quit():
	MenuSounds.stream = LoserSound
	MenuSounds.play()
	await get_tree().create_timer(1).timeout
	get_tree().quit()

func _process(delta):
	new_Selected = curr_Selected
	if Input.is_action_just_pressed("menu_up"):
		curr_Selected -= 1
	elif Input.is_action_just_pressed("menu_down"):
		curr_Selected += 1
	if new_Selected != curr_Selected:
		if curr_Selected == 4:
			curr_Selected = 1
		elif curr_Selected == 0:
			curr_Selected = 3
		change_selected()
	
	if Input.is_action_just_pressed("menu_back"):
		quit()
	
	if Input.is_action_just_pressed("ui_accept"):
		match curr_Selected:
			1:
				get_tree().change_scene_to_file("res://Scenes/test_level.tscn")
			2:
				get_tree().change_scene_to_file("res://Scenes/test_level.tscn")
				#Change to settings menu
			3:
				quit()

func change_selected():
	_selected_button.add_theme_color_override("font_color", DefaultColor)
	match  curr_Selected:
		1:
			_selected_button = PlayButton
		2:
			_selected_button = SettingsButton
		3:
			_selected_button = QuitButton
		_:
			_selected_button = PlayButton
	MenuSounds.play()
	_selected_button.add_theme_color_override("font_color", SelectedColor)
