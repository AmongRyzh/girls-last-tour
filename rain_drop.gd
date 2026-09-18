extends Area2D
class_name RainDrop

@export var SPEED : float = 1800

@export var height_to_pitch_curve : Curve

var dead : bool = false

func _physics_process(delta):
	if !dead:
		global_position.y += delta * SPEED

func _on_body_entered(body):
	print(name, " entered ", body, "!")
	if body is RainInteractable:
		$AudioStreamPlayer2D.stream = body.all_sounds.pick_random()
		$AudioStreamPlayer2D.finished.connect(queue_free)
		var semitone : int = roundi((body.middle_c_pos - body.global_position.y) / body.dist_between_semitones)
		$AudioStreamPlayer2D.pitch_scale = pow(2.0, semitone / 12.0)
		#$AudioStreamPlayer2D.pitch_scale = height_to_pitch_curve.sample(global_position.y)
		$AudioStreamPlayer2D.play()
		visible = false
		dead = true
