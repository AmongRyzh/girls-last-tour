extends StaticBody2D
class_name RainInteractable

@export_dir var raindrop_sfx_directory : String

var all_sounds : Array[AudioStreamOggVorbis]

var is_moved_by_finger : bool = false
var finger_index := -1

var mouse_inside : bool

# Called when the node enters the scene tree for the first time.
func _ready():
	all_sounds = get_all_sounds(raindrop_sfx_directory)
	
	#input_event.connect(_on_input_event)

#func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int):
	##print(name, ', _input_event(viewport, event, shape_idx), viewport = ', viewport, ' event = ', event, ' shape_idx = ', shape_idx)
	#
	#if event is InputEventScreenTouch:
		#is_moved_by_finger = event.pressed
	#
	#if event is InputEventScreenDrag:
		#if is_moved_by_finger:
			#global_position = event.position

func _mouse_enter():
	mouse_inside = true
func _mouse_exit():
	mouse_inside = false

func _input(event: InputEvent):
	if pos_inside(event.position):
		print(name, ', _input(event), event = ', event)
	
	if event is InputEventScreenTouch and pos_inside(event.position):
		is_moved_by_finger = event.pressed
		
		if !is_moved_by_finger:
			get_tree().current_scene.occupied_finger_indexes.erase(finger_index)
			finger_index = -1
	
	if event is InputEventScreenDrag:
		if is_moved_by_finger:
			if finger_index == -1:
				if event.index not in get_tree().current_scene.occupied_finger_indexes:
					finger_index = event.index
				get_tree().current_scene.occupied_finger_indexes.append(finger_index)
			
			if finger_index == event.index:
				global_position = event.position

func pos_inside(pos: Vector2) -> bool:
	var space_state = get_world_2d().direct_space_state
	
	var query = PhysicsPointQueryParameters2D.new()
	query.position = pos
	query.collide_with_bodies = true
	
	var results = space_state.intersect_point(query)
	for result in results:
		if result.rid == self.get_rid():
			return true
	
	return false

func get_all_sounds(directory_path: String) -> Array[AudioStreamOggVorbis]:
	var output : Array[AudioStreamOggVorbis]
 
	var dir = DirAccess.open(directory_path)
	if dir:
		for file_name in dir.get_files():
			if file_name.get_extension() == "remap":
				file_name = file_name.replace(".remap", "")
   
			if file_name.get_extension() == "ogg":
				var full_path = directory_path.path_join(file_name)
				output.append(load(full_path))
 
	return output
