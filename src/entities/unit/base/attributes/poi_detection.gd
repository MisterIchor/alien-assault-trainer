extends Node2D

var interval_time_base: float = 3.0
var interval_time_range: float = 2.0
var interval_chance_increments: float = 6.25

var _closest_poi: Node2D = null:
	set = _set_closest_poi
var _detection: Array[Area2D] = []
var _is_in_interval: bool = false:
	set = _set_is_in_interval
var _interval_chance: float = 0

@onready var interval_timer: Timer = $IntervalTimer



func _ready() -> void:
	for i in get_children():
		if i is Area2D:
			_detection.append(i)
	
	interval_timer.timeout.connect(_on_IntervalTimer_timeout)


func _physics_process(delta: float) -> void:
	for i in _detection:
		if not i.get_closest():
			if i == _detection.back():
				_is_in_interval = false
				_closest_poi = null
			
			continue
		
		_closest_poi = i.get_closest()
		break


func _set_is_in_interval(value: bool) -> void:
	if _is_in_interval == value:
		return
	
	_is_in_interval = value
	set_physics_process(!value)
	
	if _is_in_interval:
		var rand: float = randf_range(-interval_time_range / 2, interval_time_range / 2)
		interval_timer.start(interval_time_base + rand)
	else:
		interval_timer.stop()


func _set_closest_poi(new_closest: Node2D) -> void:
	if _closest_poi == new_closest:
		return
	
	_closest_poi = new_closest
	
	if _closest_poi:
		if randf_range(0, 100) <= _interval_chance:
			_is_in_interval = true
			_closest_poi = null
			_interval_chance = 0
			print("interval")
		else:
			_interval_chance += interval_chance_increments
	else:
		_interval_chance = 0
	
	print(_interval_chance)
	



func get_closest_poi() -> Node2D:
	return _closest_poi



func _on_IntervalTimer_timeout() -> void:
	_is_in_interval = false
