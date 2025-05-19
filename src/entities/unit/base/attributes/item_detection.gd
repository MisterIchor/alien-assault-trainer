@tool
extends "res://src/detection/radial_detection/radial_detection.gd"


#func _ready() -> void:
	#_collision_ray.add_exception(get_parent())



func _set_closest(new_closest: Node2D) -> void:
	var old_closest: Node2D = _closest
	super(new_closest)
	
	if not old_closest == _closest:
		if old_closest:
			old_closest.is_highlighted = false
		
		if _closest:
			_closest.is_highlighted = true
