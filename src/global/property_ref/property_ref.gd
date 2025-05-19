class_name PropertyRef
extends RefCounted

## Keeps a reference to a property within an [Object] that can be passed around.
##
## [PropertyRef] allows the access to a property's value without a direct reference to its [Object]. 
## In addition, it also keeps of the property's value internally for safety in case the [Object] becomes invalid and includes
## the option to automatically check for changes in the property every process frame.
##[br][br]
## [PropertyRef] requires three arguments to be passed on to [method Object.new()]: the [Object] that
## this [PropertyRef] will keep track of, the name of the property as a [String], and a [param bool]
## that determines whether the internal value should be updated automatically.
##[br][br]
## Once intialized, [PropertyRef] cannot be changed. If you wish to change the object or property being referenced,
## create a new [PropertyRef] and overwrite the reference to it.
##[br][br]
## [u]Important:[/u] While you can create a [PropertyRef] directly, it is [u]highly recommended[/u] to use [PropertyRefTracker]
## to create [PropertyRef]s instead as it will cut down on the amount of [PropertyRef]s created.

## Emits if the property in the referenced object changes to a new value. Requires [param auto_check] to be enabled
## when instanced via [method Object.new].
signal changed(new_value, old_value)

var _object: Object = null
var _property: String = ""
var _auto_check: bool = false:
	set(value):
		_auto_check = value
		
		if _auto_check:
			Engine.get_main_loop().process_frame.connect(_on_process_frame)
		elif Engine.get_main_loop().process_frame.is_connected(_on_process_frame):
			Engine.get_main_loop().process_frame.disconnect(_on_process_frame)
var _value: Variant = null
var _timer: SceneTreeTimer = null
var _is_tracked: bool = false



## [param target_object]: The object that should be referenced when getting the value of [param target_property].
##[br]
## [param target_property]: The property that is being referenced from [param target_object].
##[br]
## [param auto_check]: Checks the property every process frame for changes, emitting [signal changed] if a
## change is detected.
func _init(target_object: Object, target_property: String, auto_check: bool = false) -> void:
	_object = target_object
	_property = target_property
	_auto_check = auto_check
	
	if not Engine.is_editor_hint():
		_value = _object.get_indexed(_property)
	
	_check_if_tracked.call_deferred()



func _check_if_tracked() -> void:
	if not _is_tracked:
		print("PropertyRef: Reference not tracked. Consider using PropertyRefTracker.get_property_ref() instead.")



## Returns the value of property from the object set during initialization. Returns the internal value if
## the object is invalid and prints an error message. Updates the internal value if successful.
##[br][br]
## If [method Engine.is_editor_hint] is [param true], returns the internal value instead.
func get_value() -> Variant:
	if Engine.is_editor_hint():
		return _value
	
	if not is_object_valid():
		print("PropertyRef: object is invalid, returning internal value...")
		return _value
	
	var value_from_object: Variant = _object.get_indexed(_property)
	_value = value_from_object
	return value_from_object

## Returns the internal value. Same as [method get_value], but does not fail if the referenced object
## is invalid.
func get_value_internal() -> Variant:
	return _value

## Returns the name of the property this [PropertyRef] is referencing.
func get_property_name() -> String:
	return _property

## Returns the object this [PropertyRef] is referencing. Returns [param null] if the object is invalid.
func get_object() -> Object:
	return _object

## Return [param true] if the referenced object is valid.
func is_object_valid() -> bool:
	return is_instance_valid(_object)



func _on_process_frame() -> void:
	if not is_object_valid():
		print("PropertyRef: object is invalid, auto-update shutting off...")
		_auto_check = false
		return
	
	var value_from_object: Variant = _object.get_indexed(_property)
	
	if not value_from_object == _value:
		changed.emit(value_from_object, _value)
	
	_value = value_from_object
