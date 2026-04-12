extends Control

@onready var ResumeButton : Button = %ResumeButton
@onready var RestartButton: Button = %RestartButton
@onready var QuitButton : Button  = %QuitButton
@onready var AllButtons : Array[Button] = [ResumeButton,RestartButton,QuitButton]

@onready var _selected_button : Button = ResumeButton
var Selected_Index = 1
var New_Selected_Index = 1

@onready var MenuSounds : AudioStreamPlayer2D = %MenuSounds

@onready var ChangeSelectionSound = preload("res://Sounds/Menu Sounds/ChangeSelection.ogg")
@onready var LoserSound = preload("res://Sounds/Menu Sounds/Loser.ogg")


func _ready():
	for curr_button in AllButtons:
		curr_button.connect("HoveredOver",change_hover)
		curr_button.connect("ClickedButton",ActivateButton)
		
	hide()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
func quit():
	MenuSounds.stream = LoserSound
	get_tree().paused = false
	MenuSounds.play()
	await get_tree().create_timer(1).timeout
	get_tree().quit()

func _process(_elta):
	if $".".visible:
		if get_tree().paused:
			if Input.is_action_just_pressed("menu_quit"):
				resume()
				
			New_Selected_Index = Selected_Index
			if Input.is_action_just_pressed("menu_up"):
				New_Selected_Index -= 1
			elif Input.is_action_just_pressed("menu_down"):
				New_Selected_Index += 1
			
			if Selected_Index != New_Selected_Index:
				change_selected()
			
			if Input.is_action_just_pressed("menu_accept"):
				ActivateButton(_selected_button)
	elif Input.is_action_just_pressed("menu_quit") and !get_tree().paused:
		pause()
		ResumeButton.grab_focus()


func change_hover(PassedButton : Button):
	_selected_button.release_focus()
	match  PassedButton.text:
		"Resume":
			_selected_button = ResumeButton
			Selected_Index = 1
		"Restart":
			_selected_button = RestartButton
			Selected_Index = 2
		"Give Up":
			_selected_button = QuitButton
			Selected_Index = 3
		_:
			_selected_button = ResumeButton
			Selected_Index = 1
	PassedButton.grab_focus()
	MenuSounds.play()

func ActivateButton(PassedButton : Button):
	match PassedButton.text:
		"Resume":
			resume()
		"Restart":
			restart()
		"Give Up":
			quit()
	MenuSounds.play()
	
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
			_selected_button = ResumeButton
		2:
			_selected_button = RestartButton
		3:
			_selected_button = QuitButton
		_:
			_selected_button = ResumeButton
	_selected_button.grab_focus()
	MenuSounds.play()

func resume():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	get_tree().paused = false
	hide()

func pause():
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	$".".visible = true

func restart():
	get_tree().paused = false
	get_tree().reload_current_scene()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
