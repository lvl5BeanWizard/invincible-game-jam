extends Node3D

@onready var character = $Character
@onready var minimap_cam = $Minimap/PanelContainer/SubViewportContainer/SubViewport/Camera3D

@onready var sentry_spawn1 = $"SentrySpawns/1"
@onready var sentry_spawn2 = $"SentrySpawns/2"
@onready var sentry_spawn3 = $"SentrySpawns/3"

var sentry_gun
var sentry_strength = 2
var active_sentrys = []

# Called when the node enters the scene tree for the first time.
func _ready():
	sentry_gun = preload("res://Scenes/sentry_gun.tscn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	minimap_cam.global_position.x = character.global_position.x
	minimap_cam.global_position.z = character.global_position.z

func spawn_sentry(num: int):
	if num == 1:
		var s = sentry_gun.instantiate()
		s.global_transform = sentry_spawn1.global_transform
		get_tree().current_scene.add_child(s)
		active_sentrys.append(s)
	elif num == 2:
		var s = sentry_gun.instantiate()
		s.global_transform = sentry_spawn2.global_transform
		s.set_strength(sentry_strength)
		get_tree().current_scene.add_child(s)
		active_sentrys.append(s)
	elif num == 3:
		var s = sentry_gun.instantiate()
		s.global_transform = sentry_spawn3.global_transform
		s.set_strength(sentry_strength)
		get_tree().current_scene.add_child(s)
		active_sentrys.append(s)

func upgrade_sentrys():
	for s in active_sentrys:
		sentry_strength += 2
		s.set_strength(sentry_strength)
