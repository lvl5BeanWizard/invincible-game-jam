extends Node2D

@onready var enemy_spawner = get_node("/root/TestLevel/EnemySpawnerSystem")

@onready var ChangeSelectionSound = preload("res://Sounds/Menu Sounds/ChangeSelection.ogg")

var card: PackedScene = preload("res://Scenes/power_up_card.tscn")
var ControllerIcon = preload("res://Textures/ControlIcons/Controller/playstation_button_color_square_outline.png")
var KBMIcon = preload("res://Textures/ControlIcons/Keyboard/keyboard_tab.png")
var powerup_cards = []
var picked_powerups = []

#using this to track which powerup is selected for the controller input
var selected = 1
var new_selection = 1

signal got_powerup(powerup: Powerup)

var common_powerups: Array[Powerup] = [
	preload("res://Resources/Powerups/Utility/ServerHealOverTime.tres"),
	preload("res://Resources/Powerups/Utility/Jetpack.tres"),
	preload("res://Resources/Powerups/Offensive/LaserUpgrade.tres")
	]
	
var uncommon_powerups: Array[Powerup] = [
	preload("res://Resources/Powerups/Defensive/SentryGun.tres"),
	preload("res://Resources/Powerups/Defensive/ArmorPlating.tres"),
	preload("res://Resources/Powerups/Offensive/RocketLauncher.tres")
]

var rare_powerups: Array[Powerup] = [
]

#upgrades
var server_heal_upgrade = preload("res://Resources/Powerups/Utility/ServerHealOverTimeUpgrade.tres")
var sentry2_upgrade = preload("res://Resources/Powerups/Defensive/SentryGun2.tres")
var sentry3_upgrade = preload("res://Resources/Powerups/Defensive/SentryGun3.tres")
var generic_sentry_upgrade = preload("res://Resources/Powerups/Defensive/SentryUpgrade.tres")
var rocket_upgrade = preload("res://Resources/Powerups/Offensive/RocketLauncherUpgrade.tres")

var pickable_powerups: Array[Powerup] = []

func _ready():
	enemy_spawner.wave_cleared.connect(_on_wave_cleared)
	pickable_powerups += common_powerups

func _unhandled_input(_event: InputEvent) -> void:
		if Input.is_action_just_pressed("KBMKeys"):
			$CanvasLayer/RerollButton.set_button_icon(KBMIcon)
		elif Input.is_action_just_pressed("ControllerKeys"):
			$CanvasLayer/RerollButton.set_button_icon(ControllerIcon)

func pick_powerups():
	for p in powerup_cards:
		p.queue_free()
	powerup_cards.clear()
	
	var card1 : PowerupCard = card.instantiate()
	card1.powerup = pickable_powerups.pick_random()
	card1.position = %Spot1.position
	get_tree().root.add_child(card1)
	card1.powerup_picked.connect(_on_powerup_picked)
	powerup_cards.append(card1)
	
	var card2 : PowerupCard = card.instantiate()
	card2.powerup = pickable_powerups.pick_random()
	card2.position = %Spot2.position
	get_tree().root.add_child(card2)
	card2.powerup_picked.connect(_on_powerup_picked)
	powerup_cards.append(card2)
	
	var card3 : PowerupCard = card.instantiate()
	card3.powerup = pickable_powerups.pick_random()
	card3.position = %Spot3.position
	get_tree().root.add_child(card3)
	card3.powerup_picked.connect(_on_powerup_picked)
	powerup_cards.append(card3)
	
	update_selected()
	
func is_powerup_already_picked(powerup: Powerup):
	if "Upgrade" in powerup.name:
		#always allow upgrades to existing powerups
		return false
	if powerup in picked_powerups:
		return true

func _on_powerup_picked(powerup: Powerup):
	got_powerup.emit(powerup)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	picked_powerups.append(powerup)
	
	if "Upgrade" not in powerup.name:
		pickable_powerups.erase(powerup)
	
	if powerup.name == "Rocket Launcher":
		pickable_powerups.append(rocket_upgrade)
	elif powerup.name == "Server Heals":
		pickable_powerups.append(server_heal_upgrade)
	elif powerup.name == "Sentry Gun":
		pickable_powerups.append(sentry2_upgrade)
		pickable_powerups.append(generic_sentry_upgrade)
	elif powerup.name == "Sentry Gun 2":
		pickable_powerups.append(sentry3_upgrade)
	
	#clear the cards
	for card in powerup_cards:
		card.queue_free()
	powerup_cards = []
	visible = false
	$CanvasLayer.visible = false

func _on_reroll_button_pressed():
	pick_powerups()

func _process(delta):
	if visible:
		#reroll
		new_selection = selected
		if Input.is_action_just_pressed("reroll"):
			pick_powerups()
		elif Input.is_action_just_pressed("left"):
				selected -= 1
		elif Input.is_action_just_pressed("right"):
				selected += 1
		elif Input.is_action_just_pressed("jump"):
			_on_powerup_picked(powerup_cards[selected].get_powerup())
		
		if selected > 2:
			selected = 0
		elif selected < 0:
			selected = 2
			
		if new_selection != selected:
			update_selected()

func update_selected():
	for p in powerup_cards:
		p.deselect()
	powerup_cards[selected].select()
	$Sounds.play()

func _on_wave_cleared():
	visible = true
	$CanvasLayer.visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if picked_powerups.size() == 1:
		pickable_powerups += uncommon_powerups
	elif picked_powerups.size() == 3:
		pickable_powerups += rare_powerups
		
	pick_powerups()
