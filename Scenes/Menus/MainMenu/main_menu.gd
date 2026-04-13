extends Control

@onready var PlayButton : Button = %PlayButton
@onready var ControlsButton: Button = %ControlsButton
@onready var CreditsButton: Button = %CreditsButton
@onready var QuitButton : Button  = %QuitButton
@onready var AllButtons : Array[Button] = [PlayButton,ControlsButton,CreditsButton,QuitButton]

@onready var _selected_button : Button = PlayButton
var Selected_Index = 1
var New_Selected_Index = 1

@onready var MenuSounds : AudioStreamPlayer2D = %MenuSounds
@onready var BGM : AudioStreamPlayer2D = %BGM

@onready var ChangeSelectionSound = preload("res://Sounds/Menu Sounds/ChangeSelection.ogg")
@onready var LoserSound = preload("res://Sounds/Menu Sounds/Loser.ogg")


func _ready():
	for i in AllButtons:
		i.connect("HoveredOver",change_hover)
		i.connect("ClickedButton",ActivateButton)
	PlayButton.grab_focus()
	MenuSounds.stream = ChangeSelectionSound
	
func quit():
	MenuSounds.stream = LoserSound
	MenuSounds.play()
	await get_tree().create_timer(1).timeout
	get_tree().quit()

func _process(_elta):
	New_Selected_Index = Selected_Index
	if Input.is_action_just_pressed("menu_up"):
		New_Selected_Index -= 1
	elif Input.is_action_just_pressed("menu_down"):
		New_Selected_Index += 1
	
	if Selected_Index != New_Selected_Index:
		change_selected()
	
	if Input.is_action_just_pressed("menu_quit"):
		quit()
	
	if Input.is_action_just_pressed("menu_accept"):
		ActivateButton(_selected_button)
	
	

func change_hover(PassedButton : Button):
	_selected_button.release_focus()
	match  PassedButton.text:
		"Play":
			_selected_button = PlayButton
			Selected_Index = 1
		"Controls":
			_selected_button = ControlsButton
			Selected_Index = 2
		"Credits":
			_selected_button = CreditsButton
			Selected_Index = 3
		"Give Up":
			_selected_button = QuitButton
			Selected_Index = 4
		_:
			_selected_button = PlayButton
			Selected_Index = 1
	PassedButton.grab_focus()
	
	MenuSounds.play()

func ActivateButton(PassedButton : Button):
	match PassedButton.text:
		"Play":
			get_tree().change_scene_to_file("res://Scenes/test_level.tscn")
		"Credits":
			get_tree().change_scene_to_file("res://Scenes/Menus/Credits/CreditsMenu.tscn")
		"Controls":
			get_tree().change_scene_to_file("res://Scenes/Menus/Controls/ControlsMenu.tscn")
		"Give Up":
			quit()
	MenuSounds.play()
	print_debug(PassedButton.text)
	
func change_selected():
	var Menulength = $"Horizonal Center/Vertical Center/Selections".get_children().size()
	if New_Selected_Index == Menulength+1:
		Selected_Index = 1
	elif New_Selected_Index == 0:
		Selected_Index = Menulength
	else:
		Selected_Index = New_Selected_Index
		
	match  Selected_Index:
		1:
			_selected_button = PlayButton
		2:
			_selected_button = ControlsButton
		3:
			_selected_button = CreditsButton
		4:
			_selected_button = QuitButton
		_:
			_selected_button = PlayButton
	_selected_button.grab_focus()
	MenuSounds.play()
