extends Node2D

@onready var enemy_spawner = get_node("/root/TestLevel/EnemySpawnerSystem")

var card: PackedScene = preload("res://Scenes/power_up_card.tscn")
var powerup_cards = []

#using this to track which powerup is selected for the controller input
var selected = 1

signal got_powerup(powerup: Powerup)

var common_powerups: Array[Powerup] = [
	preload("res://Resources/Powerups/Utility/ServerHealOverTime.tres"),
	preload("res://Resources/Powerups/Offensive/ChainsawArm.tres"),
	preload("res://Resources/Powerups/Utility/Jetpack.tres"),
	preload("res://Resources/Powerups/Offensive/RocketLauncher.tres"),
	preload("res://Resources/Powerups/Offensive/BuzzSaws.tres")
	
]

func _ready():
	enemy_spawner.wave_cleared.connect(_on_wave_cleared)

func pick_powerups():
	for p in powerup_cards:
		p.queue_free()
	powerup_cards.clear()
	
	var card1 : PowerupCard = card.instantiate()
	card1.powerup = common_powerups.pick_random()
	card1.position = $Spot1.position
	get_tree().root.add_child(card1)
	card1.powerup_picked.connect(_on_powerup_picked)
	powerup_cards.append(card1)
	
	var card2 : PowerupCard = card.instantiate()
	card2.powerup = common_powerups.pick_random()
	card2.position = $Spot2.position
	get_tree().root.add_child(card2)
	card2.powerup_picked.connect(_on_powerup_picked)
	powerup_cards.append(card2)
	
	var card3 : PowerupCard = card.instantiate()
	card3.powerup = common_powerups.pick_random()
	card3.position = $Spot3.position
	get_tree().root.add_child(card3)
	card3.powerup_picked.connect(_on_powerup_picked)
	powerup_cards.append(card3)
	
	update_selected()
	
func _on_powerup_picked(powerup: Powerup):
	got_powerup.emit(powerup)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	#clear the cards
	for card in powerup_cards:
		card.queue_free()
	powerup_cards = []
	visible = false

func _on_reroll_button_pressed():
	pick_powerups()

func _process(delta):
	if visible:
		#reroll
		if Input.is_action_just_pressed("square"):
			pick_powerups()
		elif Input.is_action_just_pressed("left") or Input.is_action_just_pressed("dpad_left"):
			if selected > 0:
				selected -= 1
				update_selected()
		elif Input.is_action_just_pressed("right") or Input.is_action_just_pressed("dpad_right"):
			if selected < 2:
				selected += 1
				update_selected()
		elif Input.is_action_just_pressed("jump"):
			_on_powerup_picked(powerup_cards[selected].get_powerup())

func update_selected():
	for p in powerup_cards:
		p.deselect()
	powerup_cards[selected].select()
	print(selected)

func _on_wave_cleared():
	visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	pick_powerups()
