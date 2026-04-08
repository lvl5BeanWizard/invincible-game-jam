extends Node3D

@onready var server_loc = get_node("/root/TestLevel/Server").position
@onready var healthbar = $SubViewport/Healthbar3D

@export var health = 10

signal ded

func _ready():
	healthbar.max_value = health
	healthbar.value = health

func _process(delta):
	position = position.move_toward(server_loc, 2 * delta)

func _take_damage(damage):
	health -= damage
	healthbar.value = health
	if health <= 0:
		#kys
		ded.emit()
		self.queue_free()
