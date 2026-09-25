extends Node2D
class_name BeatmapManager

@export var current_beatmap : Beatmap
@export var rain_drop: PackedScene

@export var middle_c_pos : float = 363.0
@export var dist_between_semitones : float = 20.0

var middle_c_time_diff : float = 0.36
var distance_between_semitones_time_diff : float = 0.015

var current_previews : Array[Preview]

class Preview:
	var pos: Vector2
	var radius: float = 20
	var color: Color = Color(Color.LIGHT_BLUE, 0)

var start_early_time : float = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	if !current_beatmap:
		return
	
	_run_previews()
	
	await get_tree().create_timer(current_beatmap.start_delay - current_beatmap.delay_before_loop).timeout
	
	_run_through_hit_objects()

func _run_through_hit_objects():
	for hit_object in current_beatmap.hit_objects:
		_handle_hit_object(hit_object)

func _run_previews():
	for hit_object in current_beatmap.hit_objects:
		prints("PREV", hit_object)
		
		var fall_time : float = abs(-150 - (middle_c_pos - dist_between_semitones * hit_object.note + 12 * hit_object.octave - 48)) / rain_drop.instantiate().SPEED
		
		var time_with_delay : float = fall_time + 0.4
		
		prints("PREV", fall_time, time_with_delay, hit_object.time, hit_object.time - time_with_delay, current_beatmap.start_delay - current_beatmap.delay_before_loop + hit_object.time - time_with_delay)
		
		get_tree().create_timer(current_beatmap.start_delay - current_beatmap.delay_before_loop + hit_object.time - time_with_delay).timeout.connect(func(): 
			prints("PREV", "timeout!")
			_handle_preview(hit_object, time_with_delay)
		)

func _handle_hit_object(hit_object : HitObject):
	var semitone = hit_object.note + 12 * hit_object.octave - 48
	print(semitone)
	
	var time_diff : float = distance_between_semitones_time_diff * -semitone
	prints(middle_c_time_diff, distance_between_semitones_time_diff * semitone)
	
	var fall_time : float = abs(-150 - (middle_c_pos - dist_between_semitones * semitone)) / rain_drop.instantiate().SPEED
	$"../NoteLabel4".text = str(fall_time)
	
	var time : float = hit_object.time - fall_time
	
	prints(time_diff, time, hit_object.time, time + current_beatmap.delay_before_loop)
	
	await get_tree().create_timer(time + current_beatmap.delay_before_loop).timeout
	
	$"../NoteLabel2".text = HitObject.Notes.keys()[wrapi(semitone, 0, 12)] + str(floori((float(semitone) / 12) + 4))
	
	if hit_object == current_beatmap.hit_objects[-1]:
		get_tree().create_timer(current_beatmap.delay_before_loop).timeout.connect(_run_through_hit_objects)
	
	var new_rain_drop : RainDrop = rain_drop.instantiate()
	print(new_rain_drop.name)
	new_rain_drop.position = Vector2(hit_object.x_pos, -150)
	new_rain_drop.target_semitone = semitone
	add_child(new_rain_drop)
	
	await get_tree().create_timer(fall_time).timeout
	print('timeout 2!')
	
	if !new_rain_drop:
		return
	
	var rain_interactables : Array[Node] = get_tree().get_nodes_in_group('rain_interactable')
	rain_interactables.sort_custom(func(a, b):
		return a.global_position.distance_squared_to(new_rain_drop.global_position) < b.global_position.distance_squared_to(new_rain_drop.global_position)
	)
	
	#print(rain_interactables[0])
	$"../NoteLabel5".text = str(roundi((middle_c_pos - rain_interactables[0].global_position.y) / dist_between_semitones)) + " - " + str(semitone) + " = " + str(abs(roundi((middle_c_pos - rain_interactables[0].global_position.y) / dist_between_semitones) - semitone))
	
	if abs(roundi((middle_c_pos - rain_interactables[0].global_position.y) / dist_between_semitones) - semitone) <= 3:
		$"../NoteLabel5".text += " (true!!)"
		new_rain_drop.play_sound_and_kill_myself(pow(2.0, semitone / 12.0), rain_interactables[0])

func _handle_preview(hit_object : HitObject, time : float):
	var semitone = hit_object.note + 12 * hit_object.octave - 48
	
	var new_prev = Preview.new()
	new_prev.pos = Vector2(hit_object.x_pos, middle_c_pos - dist_between_semitones * semitone)
	current_previews.append(new_prev)
	
	if hit_object == current_beatmap.hit_objects[-1]:
		_run_previews()
		#get_tree().create_timer(current_beatmap.delay_before_loop).timeout.connect(_run_through_hit_objects)
	
	await get_tree().create_timer(0.2).timeout
	
	var opening_subtween = create_tween()
	opening_subtween.set_parallel()
	opening_subtween.tween_property(current_previews[current_previews.find(new_prev)], 'radius', 50, time + 0.4)
	opening_subtween.tween_property(current_previews[current_previews.find(new_prev)], 'color', Color.LIGHT_BLUE, time + 0.4)
	
	var closing_subtween = create_tween()
	closing_subtween.set_parallel()
	closing_subtween.tween_property(current_previews[current_previews.find(new_prev)], 'radius', 65, 0.1)
	closing_subtween.tween_property(current_previews[current_previews.find(new_prev)], 'color', Color(Color.LIGHT_BLUE, 0), 0.1)
	closing_subtween.tween_callback(func(): current_previews[current_previews.find(new_prev)].radius = 20)
	
	var tween = create_tween()
	tween.tween_subtween(opening_subtween)
	tween.tween_subtween(closing_subtween)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	queue_redraw()

func _draw():
	for preview in current_previews:
		draw_circle(preview.pos, preview.radius, preview.color)
