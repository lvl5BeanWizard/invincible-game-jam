extends Node3D


func emit_smoke(emit: bool):
	$Fire.emitting = emit
	if emit:
		if not $JetpackNoise.playing:
			$JetpackNoise.play()
	else:
		$JetpackNoise.stop()
