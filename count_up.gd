extends Node2D

var time_elapsed: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time_elapsed += delta #* (Engine.time_scale ** -1)
	
	# Format into minutes and seconds
	var minutes = int(time_elapsed / 60)
	var seconds = int(time_elapsed) % 60
	var msec = int((time_elapsed - int(time_elapsed)) * 100)
	
	# Update label text
	#print (time_elapsed, " (%02d:%02d:%02d)" % [minutes, seconds, msec])
	$Label.text = str(time_elapsed) + " (%02d:%02d:%02d)" % [minutes, seconds, msec]
