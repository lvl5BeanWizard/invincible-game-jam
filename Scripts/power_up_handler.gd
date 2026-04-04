extends Node2D

var card: PackedScene = preload("res://Scenes/power_up_card.tscn")

var common_powerups: Array[Powerup] = [
	preload("res://Resources/Powerups/Common/ArmorPlating.tres"),
	preload("res://Resources/Powerups/Common/ChainsawArm.tres"),
	preload("res://Resources/Powerups/Common/Jetpack.tres")
]

func _ready():
	pass

func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		pick_powerups()

func pick_powerups():
	var card1 : PowerupCard = card.instantiate()
	card1.powerup = common_powerups.pick_random()
	card1.position = $Spot1.position
	get_tree().root.add_child(card1)
	
	var card2 : PowerupCard = card.instantiate()
	card2.powerup = common_powerups.pick_random()
	card2.position = $Spot2.position
	get_tree().root.add_child(card2)
	
	var card3 : PowerupCard = card.instantiate()
	card3.powerup = common_powerups.pick_random()
	card3.position = $Spot3.position
	get_tree().root.add_child(card3)
