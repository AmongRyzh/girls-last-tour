extends Area2D
class_name RainDrop

@export var SPEED : float = 1800

var dead : bool = false

func _physics_process(delta):
	if !dead:
		global_position.y += delta * SPEED

func _on_body_entered(body):
	print(name, " entered ", body, "!")
	if body is RainInteractable:
		$AudioStreamPlayer2D.stream = body.all_sounds.pick_random()
		$AudioStreamPlayer2D.finished.connect(queue_free)
		$AudioStreamPlayer2D.pitch_scale = randf_range(0.6, 1.4)
		$AudioStreamPlayer2D.play()
		visible = false
		dead = true
