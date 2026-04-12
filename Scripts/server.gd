extends Node3D

var server_health = 100

func _take_damage(damage: int):
	server_health -= damage
	$ProgressBar.value = server_health
