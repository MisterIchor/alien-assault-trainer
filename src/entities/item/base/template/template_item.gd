@tool
class_name ItemTemplate
extends Resource

@export var sprite_world: Texture = null
@export var sprite_equipped: Texture = null
@export var sound_bank: SoundBank = null
@export var weight: int = 0
@export var collision_poly: PackedVector2Array = []
@export var setup_script: GDScript = null:
	set = set_setup_script
@export var configurable_values: Dictionary[String, Variant] = {}



func set_setup_script(new_script: GDScript) -> void:
	setup_script = new_script
	
	if not Engine.is_editor_hint():
		return
	
	if not setup_script:
		return
	
	if not setup_script.get_global_name() == "ItemSetup":
		if not setup_script.get_base_script().get_global_name() == "ItemSetup":
			printerr("Script does not extend ItemSetup, aborting...")
			return
	
	#var setup: ItemSetup = setup_script.new()
	#
	#for i in setup.configurable_values.keys():
		#if not configurable_values.has(i):
			#configurable_values[i] = setup.configurable_values[i]
	#
	#notify_property_list_changed()
