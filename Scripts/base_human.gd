extends Node3D

@onready var server = get_node("/root/TestLevel/Server")
@onready var server_loc = server.position
@onready var healthbar = $SubViewport/Healthbar3D
@onready var human_skin = $HumanSkin

@export var health = 10
@export var damage = 3

var running = true

signal ded

func _ready():
	healthbar.max_value = health
	healthbar.value = health

func _process(delta):
	if running:
		_handle_run(delta)
	else:
		_handle_attack(delta)

func _handle_run(delta):
	human_skin.look_at(server_loc)
	position = position.move_toward(server_loc, 5 * delta)
	
func _handle_attack(delta):
	human_skin.rotation_degrees.x = -90
	human_skin.play_anim("attack/Root|Attack")


func _take_damage(damage):
	health -= damage
	healthbar.value = health
	if health <= 0:
		#kys
		ded.emit()
		self.queue_free()


func _on_area_3d_area_entered(area):
	if area.is_in_group("Server"):
		running = false
	server._take_damage(damage)
	$AttackCooldown.start()


func _on_attack_cooldown_timeout():
	server._take_damage(damage)
	$AttackCooldown.start()
