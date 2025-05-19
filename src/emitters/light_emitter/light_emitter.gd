@tool
class_name LightEmitter
extends Node2D

## A complex lighting node that uses [LightEmitterLayer] nodes to create detailed lighting. Supports
## faux 3D rotation and limited animation.

## Enumerator used for [member color_transition_type]. Controls the transition between colors when
## [member color_transition_speed] > 0.0 and colors.size() > 1.
enum ColorTransitionType {
	## No transitions occur. All [LightEmitterLayer]s will inherit the first color in [member colors].
	NONE, 
	## Colors will abrruptly changed between colors within [member colors].
	STROBE, 
	## Color will smoothly transition between colors within [member colors] through linear interpolation.
	SMOOTH
}
## Emunerator used for controlling the intial direction [LightEmitterLayer] nodes will turn.
enum RotationAnimDirBehavior {
	## [LightEmitterLayer] nodes will turn in the direction assigned within [LightEmitterTemplate].
	NORMAL, 
	## [LightEmitterLayer] nodes will turn in the direction opposite of the what is assigned within [LightEmitterTemplate].
	REVERSED
}

## Template for [LightEmitter]. Controls how many [LightEmitterLayer] nodes are instanced, their transform,
## and more. See [LightEmitterTemplate] for more.
@export var template: LightEmitterTemplate = null:
	set = set_template
## Overall size of this [LightEmitter]. Sets the [member PointLight2D.texture_scale] of each [LightEmitterLayer]
## node to this value when set.
@export var size: float = 1.0:
	set = set_size
## Overall brightness of this [LightEmitter]. When set, sets the [member PointLight2D.energy] of each
## [LightEmitterLayer] to this value times the value found in [member LightEmitterTemplate.layers] energy_base
## for that layer. 
@export var brightness: float = 1.0:
	set = set_brightness
@export_group("Color")
## A [PackedColorArray] containing the colors used by this [LightEmitter]. By default, [member colors]
## will always contain [member Color.WHITE] as the first color, and will append it to the array if an
## empty array is assigned.
##[br][br]
## [b]Note:[/b] Multiple colors have no effect if [member color_transition_type] is set to [member ColorTransitionType.NONE].
@export_color_no_alpha var colors: PackedColorArray = [Color.WHITE]:
	set = set_colors
## Controls the color trasition type. See [member ColorTransitionType] for more.
@export var color_transition_type: ColorTransitionType = ColorTransitionType.NONE:
	set = set_color_transition_type
## Sets how fast the colors will change per process frame, according to [member ColorTransitionType].
@export var color_change_speed: float = 1.0:
	set = set_color_change_speed
@export_group("Rotation")
## Sets the rotation_y of each [LightEmitterLayer]. Will set [member rotation_speed] to 0.0 if set. 
## Keep in mind that settings within [member LightEmitterTemplate.layers] will affected the final rotation 
## of each [LightEmitterLayer].
@export_range(-180, 180, 1.0, "radians_as_degrees") var rotation_y: float = 0.0:
	set = set_rotation_y
## Sets the rotation_z of each [LightEmitterLayer]. Will set [member rotation_speed] to 0.0 if set. 
## Keep in mind that settings within [member LightEmitterTemplate.layers] will affected the final 
## rotation of each [LightEmitterLayer].
@export_range(-180, 180, 1.0, "radians_as_degrees") var rotation_z: float = 0.0:
	set = set_rotation_z
## Sets how fast the rotation of each [LightEmitterLayer] will change per frame. Will set [member rotation_y]
## and [member rotation_z] to 0.0 if set. Keep in mind that settings within member [LightEmitterTemplate.layers] 
## will affected the final rotation of each [LightEmitterLayer].
@export_range(0, 2, 0.01, "or_greater") var rotation_speed: float = 0.0:
	set = set_rotation_speed

var _color_position: float = 0.0
var _gradient: Gradient = Gradient.new()



func _process(delta: float) -> void:
	if not color_transition_type == ColorTransitionType.NONE:
		_color_position += color_change_speed * delta
		_color_position = wrapf(_color_position, 0, colors.size())
		
		for i: LightEmitterLayer in get_children():
			i.color = Color(_gradient.sample(_color_position / colors.size()), i.color.a)
	
	if not is_zero_approx(rotation_speed):
		for i: int in get_child_count():
			var light: LightEmitterLayer = get_child(i)
			var layer: Dictionary = template.layers[i]
			
			light.increment_rotation_y((rotation_speed * layer.rotation_y_base) * layer.rotation_y_dir * delta)
			light.increment_rotation_z((rotation_speed * layer.rotation_z_base) * layer.rotation_z_dir * delta)


func _template_update() -> void:
	var layer_difference: int = template.layers.size() - get_child_count()
	
	for _i in abs(layer_difference):
		match sign(layer_difference):
			1:
				add_child(LightEmitterLayer.new())
			-1:
				remove_child(get_child(-1))
	
	for i in get_child_count():
		var layer: Dictionary = template.layers[i]
		var light: LightEmitterLayer = get_child(i)
		
		light.texture = layer.texture
		light.pos_offset = layer.offset
		light.rotation_y_limit = layer.rotation_y_limit
		light.rotation_z_limit = layer.rotation_z_limit
		light.rotation_y_behavior = layer.rotation_y_behavior
		light.rotation_z_behavior = layer.rotation_z_behavior
		light.rotation_y_offset = layer.rotation_y_offset
		light.rotation_z_offset = layer.rotation_z_offset
		light.energy = layer.energy_base
		light.texture_scale = layer.scale_base
		light.shadow_enabled = true
		light.shadow_item_cull_mask = layer.shadow_mask
	
	set_size(size)
	set_brightness(brightness)
	set_colors(colors)
	_rotation_update()


func _rotation_update() -> void:
	for i: int in get_child_count():
		var light: LightEmitterLayer = get_child(i)
		var layer: Dictionary = template.layers[i]
		
		light.reset_rotation()
		light.increment_rotation_y((rotation_y * layer.rotation_y_base) * layer.rotation_y_dir)
		light.increment_rotation_z((rotation_z * layer.rotation_z_base) * layer.rotation_z_dir)



func set_rotation_speed(new_speed: float) -> void:
	rotation_speed = new_speed
	
	if is_zero_approx(rotation_speed):
		_rotation_update()


func set_size(new_size: float) -> void:
	size = new_size
	
	if template:
		for i: int in get_child_count():
			get_child(i).texture_scale = template.layers[i].scale_base * size


func set_brightness(new_brightness: float) -> void:
	brightness = new_brightness
	
	if template:
		for i: int in get_child_count():
			get_child(i).energy = template.layers[i].energy_base * brightness


func set_colors(new_colors: PackedColorArray) -> void:
	colors = new_colors
	
	if colors.is_empty():
		colors.append(Color.WHITE)
	
	for i: LightEmitterLayer in get_children():
		i.color = Color(colors[0], i.color.a)
	
	var colors_gradient: PackedColorArray = colors.duplicate()
	_gradient.offsets = []
	_gradient.colors = []
	colors_gradient.append(colors_gradient[0])
	
	for i: int in colors_gradient.size():
		_gradient.add_point(float(i) / (colors_gradient.size() - 1), colors_gradient[i])


func set_color_transition_type(new_type: ColorTransitionType) -> void:
	color_transition_type = new_type
	_color_position = 0.0
	
	if color_transition_type == ColorTransitionType.STROBE:
		_gradient.interpolation_mode = Gradient.GRADIENT_INTERPOLATE_CONSTANT
	else:
		_gradient.interpolation_mode = Gradient.GRADIENT_INTERPOLATE_LINEAR


func set_color_change_speed(new_speed: float) -> void:
	color_change_speed = new_speed


func set_template(new_template: LightEmitterTemplate) -> void:
	if template:
		template.changed.disconnect(_template_update)
	
	template = new_template
	
	if template:
		template.changed.connect(_template_update)
		_template_update()


func set_rotation_y(new_rotation: float) -> void:
	rotation_y = new_rotation
	
	if not is_zero_approx(rotation_speed):
		rotation_speed = 0.0
	
	_rotation_update()


func set_rotation_z(new_rotation: float) -> void:
	rotation_z = new_rotation
	
	if not is_zero_approx(rotation_speed):
		rotation_speed = 0.0
	
	_rotation_update()
