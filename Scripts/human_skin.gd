extends Node3D

@onready var animation_player = $Human/AnimationPlayer
@onready var human = $Human

func play_anim(anim: String):
	animation_player.play(anim)
