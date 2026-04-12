extends Control

@onready var AllButtons : Array[Button] = []

@onready var _selected_button : Button
var Selected_Index = 1
var New_Selected_Index = 1

@onready var MenuSounds : AudioStreamPlayer2D = %MenuSounds
@onready var BGM : AudioStreamPlayer2D = %BGM

@onready var ChangeSelectionSound = preload("res://Sounds/Menu Sounds/ChangeSelection.ogg")
@onready var LoserSound = preload("res://Sounds/Menu Sounds/Loser.ogg")


func _ready():
	for curr_button in AllButtons:
		curr_button.connect("HoveredOver",change_hover)
		curr_button.connect("ClickedButton",ActivateButton)
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
			Selected_Index = 1
		"Settings":
			Selected_Index = 2
		"Credits":
			Selected_Index = 3
		"Give Up":
			Selected_Index = 4
		_:
			Selected_Index = 1
	print_debug(Selected_Index)
	PassedButton.grab_focus()
	MenuSounds.play()

func ActivateButton(PassedButton : Button):
	match PassedButton.text:

		"Play":
			get_tree().change_scene_to_file("res://Scenes/test_level.tscn")
		"Settings":
			get_tree().change_scene_to_file("res://Scenes/Menus/SettingsMenu.tscn")
		"Credits":
			get_tree().change_scene_to_file("res://Scenes/Menus/CreditsMenu.tscn")
		"Give Up":
			quit()
	
func change_selected():
	var Menulength = $"Horizonal Center/Vertical Center/Selections".get_children().size()
	if New_Selected_Index == Menulength+1:
		Selected_Index = 1
	elif New_Selected_Index == 0:
		Selected_Index = Menulength
	else:
		Selected_Index = New_Selected_Index
		
	#match  Selected_Index:
		#1:
			#_selected_button = PlayButton
		#2:
			#_selected_button = SettingsButton
		#3:
			#_selected_button = CreditsButton
		#4:
			#_selected_button = QuitButton
		#_:
			#_selected_button = PlayButton
	_selected_button.grab_focus()
	print_debug(Selected_Index)
	MenuSounds.play()
