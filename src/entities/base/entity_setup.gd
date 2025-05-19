class_name EntitySetup
extends RefCounted

## Setup script for [Entity]-derived nodes.

var entity: Node2D = null

var _tags_primary: PackedStringArray = []
var _configurable_values: Dictionary[String, Dictionary] = {}
var _states: Array[EntityState] = []



func _setup() -> void:
	return


func _overwrite_configurable_values(dict: Dictionary[String, Dictionary]) -> void:
	_configurable_values = dict

## Adds a primary tag to [Entity].
func add_tag(tag_name: String) -> void:
	_tags_primary.append(tag_name)


func add_configurable_value(catagory_name: String, value_name: String, value_default) -> void:
	var catagory: Dictionary = _configurable_values.get_or_add(catagory_name, {})
	catagory[value_name] = value_default


func add_state(state: EntityState) -> void:
	_states.append(state)


func get_tags() -> PackedStringArray:
	return _tags_primary.duplicate()


func get_configurable_value(from_catagory: String, value_name: String) -> Variant:
	if _configurable_values.has(from_catagory):
		return _configurable_values[from_catagory].get(value_name)
	
	return


func get_configurable_values() -> Dictionary[String, Dictionary]:
	return _configurable_values.duplicate(true)


func get_states() -> Array[EntityState]:
	return _states
