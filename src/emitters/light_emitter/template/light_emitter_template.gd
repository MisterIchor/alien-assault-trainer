@tool
class_name LightEmitterTemplate
extends Resource

# Really a const, but you can't make const dictionaries despite a function that 
# can make a dictionary read-only.
var LAYER_DEFAULT: Dictionary = {
	texture = load("res://src/emitters/light_emitter/template/light_gradient_texture_default.tres").duplicate(true),
	offset = Vector2(),
	rotation_y_offset = 0.0,
	rotation_z_offset = 0.0,
	scale_base = 1.0,
	rotation_y_behavior = RotationAnimBehavior.SPIN,
	rotation_y_dir = RotationAnimDir.CLOCKWISE,
	rotation_y_limit = PI,
	rotation_y_base = 1.0,
	rotation_z_behavior = RotationAnimBehavior.SPIN,
	rotation_z_dir = RotationAnimDir.CLOCKWISE,
	rotation_z_limit = PI,
	rotation_z_base = 1.0,
	shadow_mask = 0,
	energy_base = 1.0,
}

enum RotationAnimDir {CLOCKWISE = 1, COUNTER_CLOCKWISE = -1}
enum RotationAnimBehavior {SPIN, PING_PONG}

@export_tool_button("Add Layer") var _add_layer: Callable = add_layer
@export_storage var layers: Array = []
var _remove_layer_callable: Callable = remove_layer



func _init() -> void:
	# See?
	LAYER_DEFAULT.make_read_only()



func add_layer() -> void:
	layers.append(LAYER_DEFAULT.duplicate())
	notify_property_list_changed()
	emit_changed()


func remove_layer(layer_idx: int) -> void:
	layers.remove_at(layer_idx)
	notify_property_list_changed()
	emit_changed()



func _set(property: StringName, value: Variant) -> bool:
	if property.begins_with("layer_"):
		var layer_idx: int = int(property)
		var layer_property: String = property.split("-")[1]
		
		if layer_property == "remove_layer":
			_remove_layer_callable = value
			return true
		
		if not layers.get(layer_idx):
			return false
		
		layers[layer_idx][layer_property] = value
		emit_changed()
		return true
	
	return false


func _get(property: StringName) -> Variant:
	if property.begins_with("layer_"):
		var layer_idx: int = int(property)
		var layer_property: String = property.split("-")[1]
		
		if layer_property == "remove_layer":
			return _remove_layer_callable.bind(layer_idx)
		
		if not layers.get(layer_idx):
			return
		
		return layers[layer_idx][layer_property]
	
	return


func _property_can_revert(property: StringName) -> bool:
	if property.begins_with("layer_"):
		var layer_idx: int = int(property)
		var layer_property: String = property.split("-")[1]
		
		if not layers.get(layer_idx):
			return false
		
		if LAYER_DEFAULT.has(layer_property) or layer_property == "remove_layer":
			return true
	
	return false


func _property_get_revert(property: StringName) -> Variant:
	if property.begins_with("layer_"):
		var layer_idx: int = int(property)
		var layer_property: String = property.split("-")[1]
		
		if not layers.get(layer_idx):
			return
		
		if layer_property == "remove_layer":
			return
		
		return LAYER_DEFAULT.get(layer_property)
	
	return


func _get_property_list() -> Array[Dictionary]:
	var property_list: Array[Dictionary] = []
	
	for i: int in layers.size():
		property_list.append({
			name = str("Layer ", i),
			type = TYPE_NIL,
			usage = PROPERTY_USAGE_GROUP,
			hint_string = str("layer_", i, "-")
		})
		property_list.append({
			name = str("layer_", i, "-texture"),
			type = TYPE_OBJECT,
			hint = PROPERTY_HINT_RESOURCE_TYPE,
			hint_string = "Texture2D"
		})
		property_list.append({
			name = "Transform",
			type = TYPE_NIL,
			usage = PROPERTY_USAGE_SUBGROUP,
			hint_string = str("layer_", i, "_transform-")
		})
		property_list.append({
			name = str("layer_", i, "_transform-offset"),
			type = TYPE_VECTOR2,
		})
		property_list.append({
			name = str("layer_", i, "_transform-rotation_y_offset"),
			type = TYPE_FLOAT,
			hint = PROPERTY_HINT_RANGE,
			hint_string = "-180,180,1,radians_as_degrees"
		})
		property_list.append({
			name = str("layer_", i, "_transform-rotation_z_offset"),
			type = TYPE_FLOAT,
			hint = PROPERTY_HINT_RANGE,
			hint_string = "-180,180,1,radians_as_degrees"
		})
		property_list.append({
			name = str("layer_", i, "_transform-scale_base"),
			type = TYPE_FLOAT,
			hint = PROPERTY_HINT_RANGE,
			hint_string = "0,2,0.01,or_greater"
		})
		property_list.append({
			name = "Y-axis Animation",
			type = TYPE_NIL,
			usage = PROPERTY_USAGE_SUBGROUP,
			hint_string = str("layer_", i, "_animation_y-")
		})
		property_list.append({
			name = str("layer_", i, "_animation_y-rotation_y_behavior"),
			type = TYPE_INT,
			hint = PROPERTY_HINT_ENUM,
			hint_string = ",".join(RotationAnimBehavior.keys())
		})
		property_list.append({
			name = str("layer_", i, "_animation_y-rotation_y_limit"),
			type = TYPE_FLOAT,
			hint = PROPERTY_HINT_RANGE,
			hint_string = "0,180,1.0,radians_as_degrees"
		})
		property_list.append({
			name = str("layer_", i, "_animation_y-rotation_y_dir"),
			type = TYPE_INT,
			hint = PROPERTY_HINT_ENUM,
			# That's right, we're gonna cheat.
			hint_string = ",".join([str(RotationAnimDir.keys()[0], ":", RotationAnimDir.CLOCKWISE),
					str(RotationAnimDir.keys()[1], ":", RotationAnimDir.COUNTER_CLOCKWISE)])
		})
		property_list.append({
			name = str("layer_", i, "_animation_y-rotation_y_base"),
			type = TYPE_FLOAT,
			hint = PROPERTY_HINT_RANGE,
			hint_string = "0,2,0.01,or_greater"
		})
		property_list.append({
			name = "Z-axis Animation",
			type = TYPE_NIL,
			usage = PROPERTY_USAGE_SUBGROUP,
			hint_string = str("layer_", i, "_animation_z-")
		})
		property_list.append({
			name = str("layer_", i, "_animation_z-rotation_z_behavior"),
			type = TYPE_INT,
			hint = PROPERTY_HINT_ENUM,
			hint_string = ",".join(RotationAnimBehavior.keys())
		})
		property_list.append({
			name = str("layer_", i, "_animation_z-rotation_z_limit"),
			type = TYPE_FLOAT,
			hint = PROPERTY_HINT_RANGE,
			hint_string = "0,180,1.0,radians_as_degrees"
		})
		property_list.append({
			name = str("layer_", i, "_animation_z-rotation_z_dir"),
			type = TYPE_INT,
			hint = PROPERTY_HINT_ENUM,
			# That's right, we're gonna cheat. x2
			hint_string = ",".join([str(RotationAnimDir.keys()[0], ":", RotationAnimDir.CLOCKWISE),
					str(RotationAnimDir.keys()[1], ":", RotationAnimDir.COUNTER_CLOCKWISE)])
		})
		property_list.append({
			name = str("layer_", i, "_animation_z-rotation_z_base"),
			type = TYPE_FLOAT,
			hint = PROPERTY_HINT_RANGE,
			hint_string = "0,2,0.01,or_greater"
		})
		property_list.append({
			name = "Misc",
			type = TYPE_NIL,
			usage = PROPERTY_USAGE_SUBGROUP,
			hint_string = str("layer_", i, "_misc-")
		})
		property_list.append({
			name = str("layer_", i, "_misc-shadow_mask"),
			type = TYPE_INT,
			hint = PROPERTY_HINT_LAYERS_2D_RENDER
		})
		property_list.append({
			name = str("layer_", i, "_misc-energy_base"),
			type = TYPE_FLOAT,
			hint = PROPERTY_HINT_RANGE,
			hint_string = "0,2,0.01,or_greater"
		})
		property_list.append({
			name = str("layer_", i, "-remove_layer"),
			type = TYPE_CALLABLE,
			hint = PROPERTY_HINT_TOOL_BUTTON,
			usage = PROPERTY_USAGE_EDITOR,
			hint_string = "Remove Layer"
		})
	#
	return property_list
