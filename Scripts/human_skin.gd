extends Node3D

@onready var animation_player = $AnimationPlayer
@onready var human = $Human

func play_anim(anim: String):
	if animation_player != null:
		animation_player.play(anim)
