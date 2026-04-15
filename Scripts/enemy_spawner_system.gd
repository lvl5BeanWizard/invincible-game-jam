extends Node3D

@export var spawn1: Node3D
@export var spawn2: Node3D
@export var spawn3: Node3D
@export var spawn4: Node3D

@onready var curr_wave = 0

signal wave_cleared

#dict for number of enemies to spawn each wave
#wave:num_of_dudes
#TODO no idea how balanced these numbers are
@onready var human_dict = {
	1:1,
	2:3,
	3:5,
	4:10,
	5:15,
	6:25,
	7:40,
	8:75
}

#the dudes to spawn
@onready var human1 = preload("res://Scenes/base_human.tscn")
@onready var human_w_bat = preload("res://Scenes/base_human_2.tscn")
@onready var boss_human = preload("res://Scenes/boss_human.tscn")

#rng for where to spawn em
@onready var rand = RandomNumberGenerator.new()
#counter for when to end the wave
@onready var dead_humans = 0

func _ready():
	$SpawnHolder/Spawner1.position = spawn1.position
	$SpawnHolder/Spawner2.position = spawn2.position
	$SpawnHolder/Spawner3.position = spawn3.position
	$SpawnHolder/Spawner4.position = spawn4.position

func _on_enemy_death():
	dead_humans += 1
	if dead_humans == human_dict[curr_wave]:
		$InBetweenWaves.start()
		dead_humans = 0

func spawn_humans():
	for i in range(human_dict[curr_wave]):
		var rand_num = rand.randi_range(0,4)
		var h
		if rand_num < 2:
			h = human1.instantiate()
		elif rand_num < 4:
			h = human_w_bat.instantiate()
		elif rand_num == 4:
			h = boss_human.instantiate()
		#check the children number in our spawn holder
		var spawn_length = $SpawnHolder.get_child_count() -1
		#and grab a random one in range
		rand_num = rand.randi_range(0, spawn_length)
		var spawn_pos = $SpawnHolder.get_child(rand_num).position
		h.position = spawn_pos
		h.ded.connect(_on_enemy_death)
		add_child(h)
		#sleep for a second before adding another
		await get_tree().create_timer(1.0).timeout

func _process(delta):
	pass

func update_level(level: int):
	spawn_humans()

func _on_in_between_waves_timeout():
	if curr_wave > 0:
		#upgrade time
		wave_cleared.emit()
	
		#give the player 3 seconds to choose an upgrade before starting the next wave
		await get_tree().create_timer(3.0).timeout
	
	curr_wave += 1
	print("Starting wave: ", curr_wave)
	update_level(curr_wave)
