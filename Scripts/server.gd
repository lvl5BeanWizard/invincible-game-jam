extends Node3D

var server_health = 100
var heal_over_time_amt = 0

func _take_damage(damage: int):
	server_health -= damage
	$ProgressBar.value = server_health

func set_heal_over_time(amt: int):
	heal_over_time_amt = amt
	$HealTimer.start()

func _on_heal_timer_timeout():
	server_health += heal_over_time_amt
	$ProgressBar.value = server_health
	$HealTimer.start()
	if server_health > 100:
		server_health = 100
