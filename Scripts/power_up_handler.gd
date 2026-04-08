extends Node2D

@onready var enemy_spawner = get_node("/root/TestLevel/EnemySpawnerSystem")

var card: PackedScene = preload("res://Scenes/power_up_card.tscn")
var powerup_cards = []

signal got_powerup(powerup: Powerup)

var common_powerups: Array[Powerup] = [
	preload("res://Resources/Powerups/Defensive/ArmorPlating.tres"),
	preload("res://Resources/Powerups/Offensive/ChainsawArm.tres"),
	preload("res://Resources/Powerups/Utility/Jetpack.tres")
]

func _ready():
	enemy_spawner.wave_cleared.connect(_on_wave_cleared)

func pick_powerups():
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

func _on_wave_cleared():
	visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	pick_powerups()
