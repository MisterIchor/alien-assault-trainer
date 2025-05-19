@tool
extends Resource

@export var name: String = "":
	set(value):
		name = value
		resource_name = name
@export var setup_script: GDScript = null:
	set = set_setup_script
@export_storage var configurable_values: Dictionary[String, Dictionary] = {}
@export_group("Tags", "_tags_")
@export var _tags_primary: String = "":
	set(value):
		if _tags_primary_read_only:
			return
		
		_tags_primary = value
@export var _tags_secondary: String = ""
var _configurable_values_default: Dictionary = {}
var _tags_primary_read_only: bool = true



func _get_property_list() -> Array[Dictionary]:
	var property_list: Array[Dictionary] = []
	
	property_list.append({
		name = "Configurable Values",
		type = TYPE_NIL,
		usage = PROPERTY_USAGE_GROUP,
	})
	
	for catagory: String in _configurable_values_default:
		property_list.append({
			name = catagory.capitalize(),
			type = TYPE_NIL,
			usage = PROPERTY_USAGE_SUBGROUP,
			hint_string = str("conval-", catagory, "-")
		})
		
		for value in _configurable_values_default[catagory]:
			property_list.append({
				name = str("conval-", catagory, "-", value),
				type = typeof(_configurable_values_default[catagory][value])
			})
	
	return property_list



func _set(property: StringName, value: Variant) -> bool:
	if property.begins_with("conval-"):
		var catagory_name: String = property.split("-")[1]
		var value_name: String = property.split("-")[2]
		
		if _configurable_values_default.has(catagory_name):
			if _configurable_values_default[catagory_name].has(value_name):
				configurable_values[catagory_name].set(value_name, value)
				emit_changed()
				return true
	
	return false


func _get(property: StringName) -> Variant:
	if property.begins_with("conval-"):
		var catagory_name: String = property.split("-")[1]
		var value_name: String = property.split("-")[2]
		
		if _configurable_values_default.has(catagory_name):
			if _configurable_values_default[catagory_name].has(value_name):
				return configurable_values[catagory_name].get(value_name)
	
	return


func _property_can_revert(property: StringName) -> bool:
	if property.begins_with("conval-"):
		var catagory_name: String = property.split("-")[1]
		var value_name: String = property.split("-")[2]
		
		if _configurable_values_default.has(catagory_name):
			if _configurable_values_default[catagory_name].has(value_name):
				return true
	
	return false


func _property_get_revert(property: StringName) -> Variant:
	if property.begins_with("conval-"):
		var catagory_name: String = property.split("-")[1]
		var value_name: String = property.split("-")[2]
		
		if _configurable_values_default.has(catagory_name):
			if _configurable_values_default[catagory_name].has(value_name):
				return _configurable_values_default[catagory_name].get(value_name)
	
	return



func set_setup_script(new_script: GDScript) -> void:
	setup_script = new_script
	
	if not Engine.is_editor_hint():
		return
	
	_configurable_values_default.clear()
	configurable_values.clear()
	_tags_primary_read_only = false
	_tags_primary = ""
	
	if not setup_script:
		_tags_primary_read_only = true
		notify_property_list_changed()
		return
	
	if not setup_script.get_global_name() == "EntitySetup":
		if not setup_script.get_base_script().get_global_name() == "EntitySetup":
			printerr("Script does not extend EntitySetup, aborting...")
			return
	
	var setup: EntitySetup = setup_script.new()
	
	_configurable_values_default = setup.get_configurable_values()
	configurable_values = _configurable_values_default.duplicate(true)
	_tags_primary = ", ".join(setup.get_tags())
	_tags_primary_read_only = true
	notify_property_list_changed()


func get_tags_primary() -> PackedStringArray:
	return _tags_primary.split(", ")


func get_tags_secondary() -> PackedStringArray:
	return _tags_secondary.split(", ")
