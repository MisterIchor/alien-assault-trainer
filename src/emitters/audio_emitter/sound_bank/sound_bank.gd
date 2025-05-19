@tool
class_name SoundBank
extends Resource

"""
A resource for storing sounds into catagories that can be played by AudioEmitter.

Catagories are formatted as such:
	{
		category_name = AudioStreamRandomizer
	}

Place sounds in AudioStreamRandomizer.
"""

@export var _category_name: String = ""
@export var _add_category: bool = false:
	set(value):
		if value:
			add_category(_category_name)
			_category_name = ""
@export var _category: Dictionary = {}



func add_category(category_name: String) -> void:
	if _category.get(category_name):
		printerr("category %s already exists in sound bank." % category_name)
		return
	
	_category[category_name] = AudioStreamRandomizer.new()
	notify_property_list_changed()


func get_category(category_name: String) -> AudioStreamRandomizer:
	return _category.get(category_name)
