class_name ConfProperty
extends PropertyRef

## A [PropertyRef] used by [TargetInitializer] that allows the property's value to be changed.
##
## [ConfProperty] allows a property's value to be changed in addition to being referenced via [method update_value].
## It also takes an option parameter in [method Object.new()], which is the value that will act as a default value
## that a property can be reset to via [method update_value_to_default].
##[br][br]
## When [method Engine.is_editor_hint] is [code]true[/code], the functionality of [ConfProperty] is
## limited for stability. It goes into a storage mode that allows changes to its internal value without
## type-checking or verifying if the referenced object is valid.
##[br][br]
## Like [PropertyRef], [ConfProperty] cannot be change once initialized.

var _value_default: Variant = null
var _property_ref: Dictionary = {
	"static": null,
	"auto": null
}
var _default_is_enum: bool = false



## [param default_value]: The default value of this [ConfProperty]. Must be the same type as [param target_property].
## If [code]null[/code], it will be set to the internal value at the time of initialization.
##[br]
## [param default_is_enum]: If true, treats [param default_value] as an enum. [ConfProperty] won't print an error if
## the default value is a different type and [method update_value_to_default] will always use the first key in the
## dictionary. [param default_value] must be a valid enum ([method JILibrary.is_potential_enum] must return [code]true[/code]).
## Mostly useful for [annotation @GDScript.@tool] scripts.
##[br][br]
## See [PropertyRef] for [param target_object], [param target_property], and [param auto_check].
func _init(target_object: Object, target_property: String, default_value: Variant = null, default_is_enum: bool = false, auto_check: bool = false) -> void:
	super(target_object, target_property, auto_check)
	_default_is_enum = default_is_enum
	
	if not default_value:
		_value_default = _value
		return
	
	if _default_is_enum:
		if not default_value is Dictionary:
			printerr("ConfProperty: default_is_enum is true, but default value is not a dictionary.")
			return
		
		if not JILibrary.is_potential_enum(default_value):
			printerr("ConfProperty: default value provided is not a valid enum, must be Dictionary[String][int].")
			return
		
		_value_default = default_value
		_value = JILibrary.get_from_dictionary_index(default_value, 0)
		return
	
	if not Engine.is_editor_hint():
		if not JILibrary.is_same_type(default_value, _value):
			printerr("ConfProperty: attempted to set default value with value of incompatible type %s. Setting to internal value instead." % [default_value])
			_value_default = _value
			return
	
	_value_default = default_value
	
	if Engine.is_editor_hint():
		_value = _value_default



## Updates the value of the property in the object set during initialization. Fails if the value is 
## not the same type as the referenced property or if the referenced object is invalid, printing an error message.
## Updates the internal value if successful and emits [signal PropertyRef.changed].
##[br][br]
## If called when [method Engine.is_editor_hint] is true, only updates the internal value.
func update_value(new_value: Variant) -> void:
	if not Engine.is_editor_hint():
		if not is_object_valid():
			printerr("ConfProperty: object is invalid or does not exist, aborting value update...")
			return
		
		if not JILibrary.is_same_type(_object.get_indexed(_property), new_value):
			printerr("ConfProperty: attempted to update property %s of object %s with value of incompatible type %s." % [_property, _object, new_value])
			return
		
		_object.set_indexed(_property, new_value)
	
	_value = new_value
	changed.emit()


## Calls [method update_value] with the default value as the parameter.
func update_value_to_default() -> void:
	if _default_is_enum:
		update_value(JILibrary.get_from_dictionary_index(_value_default, 0))
	
	update_value(_value_default)


## Returns the default value.
func get_value_default() -> Variant:
	return _value_default


## Returns a [PropertyRef] with the object and property name of this [ConfProperty].
func get_property_ref(auto_update: bool = false) -> PropertyRef:
	if auto_update:
		if not _property_ref.auto:
			_property_ref.auto = weakref(PropertyRefTracker.get_property_ref(_object, _property, auto_update))
		
		return _property_ref.auto
	
	if not _property_ref.static:
		_property_ref.static = weakref(PropertyRefTracker.get_property_ref(_object, _property, auto_update))
	
	return _property_ref.static


## Returns [code]true[/code] if [param default_is_enum] in [method _init] was set to [code]true[/code].
func is_default_enum() -> bool:
	return _default_is_enum
