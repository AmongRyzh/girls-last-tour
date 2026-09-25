extends Area2D
class_name RainDrop

@export var SPEED : float = 1800

@export var height_to_pitch_curve : Curve

var dead : bool = false

var target_semitone : int = -100
@export var semitone_leniency : int = 3

var time_elapsed: float = 0.0

func _ready():
	$AudioStreamPlayer2D.finished.connect(queue_free)

func _physics_process(delta):
	if !dead:
		#prints(delta, Engine.time_scale, (Engine.time_scale ** -1))
		time_elapsed += delta #* (Engine.time_scale ** -1)
		
		if $RayCast2D.is_colliding():
			_on_body_entered($RayCast2D.get_collider())
		
		global_position.y += delta * SPEED
	
	# Format into minutes and seconds
	var minutes = int(time_elapsed / 60)
	var seconds = int(time_elapsed) % 60
	var msec = int((time_elapsed - int(time_elapsed)) * 100)
	
	# Update label text
	#print (time_elapsed, " (%02d:%02d:%02d)" % [minutes, seconds, msec])
	get_tree().current_scene.get_node("NoteLabel3").text = str(time_elapsed) + " (%02d:%02d:%02d)" % [minutes, seconds, msec]

func _on_body_entered(body):
	print(name, " entered ", body, "!")
	if body is RainInteractable:
		prints(get_tree().get_first_node_in_group('beatmap_manager').middle_c_pos, get_tree().get_first_node_in_group('beatmap_manager').dist_between_semitones)
		var semitone : int = roundi((get_tree().get_first_node_in_group('beatmap_manager').middle_c_pos - body.global_position.y) / get_tree().get_first_node_in_group('beatmap_manager').dist_between_semitones)
		get_tree().current_scene.get_node("NoteLabel2").text = HitObject.Notes.keys()[wrapi(semitone, 0, 12)] + str(floori((float(semitone) / 12) + 4))
		#if abs(target_semitone - semitone) > semitone_leniency or target_semitone == -100:
		if abs(target_semitone - semitone) <= semitone_leniency and target_semitone != -100:
			visible = false
			print('invisible but still waiting for the melody')
		else:
			play_sound_and_kill_myself(pow(2.0, semitone / 12.0), body)

func play_sound_and_kill_myself(pitch: float, body: RainInteractable):
	print(name, " PLAY_SOUND_AND_K_MS called with pitch ", pitch)
	
	$AudioStreamPlayer2D.stream = body.all_sounds.pick_random()
	
	if !dead:
		print(name, " NOT DEAD!!!")
		$AudioStreamPlayer2D.pitch_scale = pitch
		$AudioStreamPlayer2D.play()
		#$AudioStreamPlayer2D.pitch_scale = height_to_pitch_curve.sample(global_position.y)
		visible = false
		dead = true
