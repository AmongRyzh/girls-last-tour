extends Resource
class_name HitObject

enum Notes {
	C, Db, D, Eb, E, F, Gb, G, Ab, A, Bb, B
}

@export_enum('0', '1', '2', '3', '4', '5', '6', '7') var octave : int
@export var note : Notes
#@export var target_pos : Vector2
@export var time : float
