extends Node3D

@export var spawn1: Node3D
@export var spawn2: Node3D
@export var spawn3: Node3D
@export var spawn4: Node3D

@onready var curr_wave = 0

#dict for number of enemies to spawn each wave
#wave:num_of_dudes
#TODO no idea how balanced these numbers are
@onready var human_dict = {
	1:10, #10 for test 
	2:5,
	3:10
}

#the dude to spawn
@onready var human1 = preload("res://Scenes/base_human.tscn")
#rng for where to spawn em
@onready var rand = RandomNumberGenerator.new()
@onready var dead_humans = 0

func _ready():
	$SpawnHolder/Spawner1.position = spawn1.position
	$SpawnHolder/Spawner2.position = spawn2.position
	$SpawnHolder/Spawner3.position = spawn3.position
	$SpawnHolder/Spawner4.position = spawn4.position

func enemy_death():
	print("enemy_death")
	dead_humans += 1
	if dead_humans == human_dict[curr_wave]:
		$InBetweenWaves.start()
		dead_humans = 0

func spawn_humans():
	for i in range(human_dict[curr_wave]):
		var h = human1.instantiate()
		print("spawning enemy")
		#check the children number in our spawn holder
		var spawn_length = $SpawnHolder.get_child_count() -1
		#and grab a random one in range
		var rand_num = rand.randi_range(0, spawn_length)
		var spawn_pos = $SpawnHolder.get_child(rand_num).position
		h.position = spawn_pos
		add_child(h)
		#sleep for a second before adding another
		await get_tree().create_timer(1.0).timeout

func _process(delta):
	pass

func update_level(level: int):
	spawn_humans()

func _on_in_between_waves_timeout():
	print("Leaving wave: ", curr_wave)
	curr_wave += 1
	update_level(curr_wave)
