class_name PropertyRefTracker
extends Object

## Manages [PropertyRef]s created via [method get_property_ref].
##
## [PropertyRefTracker] has a list of [Object]s whose properties are being referenced by a [PropertyRef].
## When a [PropertyRef] is requested via [method get_property_ref], it searches through its list for the [PropertyRef],
## creating one if a reference for the requested property does not exist. Otherwise, it will return 
## that [PropertyRef]. This ensures that the amount of [PropertyRef]s are kept to a minimum.
##[br][br]
## By default, [PropertyRefTracker] will iterate through each [Object] and [PropertyRef] to clean up any [code]null[/code]
## references every second. If faster or slower clean up is desire, set [member clean_up_rate] to a different value.

static var _references: Dictionary[Object, Dictionary] = {}
## How often [PropertyRefTracker] should attempt to remove [code]null[/code] reference. The time is 
## determined by [method Engine.get_physics_frames] % [member clean_rate], and by default is set to 
## [member Engine.physics_ticks_per_second], or once per second.
static var clean_up_rate: int = Engine.physics_ticks_per_second



func _init() -> void:
	Engine.get_main_loop().physics_frame.connect(_on_physics_frame)



static func _get_formatted_string(property_name: String, auto_check: bool) -> String:
	var formatted_string: String = property_name
	
	if auto_check:
		formatted_string += ":auto"
	
	return formatted_string


static func _cleanup() -> void:
	for i in _references.keys():
		if not is_instance_valid(i):
			_references.erase(i)
	
	for i in _references:
		for j in _references[i].keys():
			if not is_instance_valid(j):
				_references[i].erase(j)



static func get_property_ref(target_object: Object, target_property: String, auto_check: bool = false) -> PropertyRef:
	if not target_object.get(target_property):
		return
	
	var new_property_ref: PropertyRef = PropertyRef.new(target_object, target_property, auto_check)
	var formatted_string: String = _get_formatted_string(target_property, auto_check)
	new_property_ref._is_tracked = true
	
	if not _references.get(target_object):
		_references[target_object] = {}
	
	_references[target_object][formatted_string] = weakref(new_property_ref)
	return new_property_ref



static func _on_physics_frame() -> void:
	if Engine.get_physics_frames() % Engine.physics_ticks_per_second == 0:
		_cleanup()
