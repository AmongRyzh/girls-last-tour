extends StaticBody2D
class_name RainInteractable

@export_dir var raindrop_sfx_directory : String

var all_sounds : Array[AudioStreamOggVorbis]

# Called when the node enters the scene tree for the first time.
func _ready():
	all_sounds = get_all_sounds(raindrop_sfx_directory)

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
