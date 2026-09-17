extends Node2D

@export var rain_drop: PackedScene
@export var rain_drop_timer: Timer

@export var randomise_position : bool = true

@onready var indicator_container = $IndicatorContainer
var indicators = []

var occupied_finger_indexes : Array[int]

# Called when the node enters the scene tree for the first time.
func _ready():
	for indicator in indicator_container.get_children():
		indicators.append(indicator)
	
	print(get_viewport_rect().size.x)
	
	$RainDropTimer.timeout.connect(_spawn_rain_drop)

func _input(event: InputEvent):
	if event is InputEventScreenDrag:
		var i = event.index
		if i < indicators.size():
			indicators[i].show()
			indicators[i].global_position = event.position
	if event is InputEventScreenTouch and not event.pressed:
		var i = event.index
		indicators[i].hide()

func _spawn_rain_drop():
	var min_pos_x : float = 100
	var max_pos_x : float = get_viewport_rect().size.x - min_pos_x
	var pos_x : float = randf_range(min_pos_x, max_pos_x)
	
	var new_drop = rain_drop.instantiate()
	new_drop.global_position = Vector2(pos_x, -150)
	add_child(new_drop)
