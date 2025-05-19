extends Camera2D

enum ElementType {STATIC, DYNAMIC_UNIT, DYNAMIC_MOUSE}

var target_unit: Unit = null:
	set = set_target_unit
var _path_to_elements: Dictionary = {
	static_ui = [],
	dynamic_unit = [],
	dynamic_mouse = []
}

@onready var static_ui: CanvasLayer = $Static
@onready var dynamic_unit: CanvasLayer = $DynamicUnit
@onready var dynamic_mouse: CanvasLayer = $DynamicMouse



func _ready() -> void:
	add_element(preload("res://src/ui/ingame/dynamic/hotbar/hotbar.tscn"), ElementType.DYNAMIC_UNIT)
	add_element(preload("res://src/ui/ingame/dynamic/weapon_crosshair/weapon_crosshair.tscn"), ElementType.DYNAMIC_MOUSE)
	add_element(preload("res://src/ui/ingame/dynamic/chat_ingame/chat.tscn"), ElementType.DYNAMIC_UNIT)
	add_element(preload("res://src/ui/ingame/dynamic/debug/debug_hud/debug_hud.tscn"), ElementType.STATIC)


func _process(delta: float) -> void:
	if target_unit:
		global_position = target_unit.global_position
	else:
		var inputs: Array[int] = [
			Input.is_action_pressed("move_up"),
			Input.is_action_pressed("move_down"),
			Input.is_action_pressed("move_left"),
			Input.is_action_pressed("move_right"),
		]
		
		global_position += Vector2(inputs[3] - inputs[2], inputs[1] - inputs[0])
	
	if target_unit:
		for i in dynamic_unit.get_children():
			i.global_position = target_unit.global_position
	
	for i in dynamic_mouse.get_children():
		i.global_position = get_viewport().get_mouse_position()



func add_element(ui: PackedScene, element_type: ElementType) -> void:
	var new_element: Control = ui.instantiate()
	
	match element_type:
		ElementType.STATIC:
			static_ui.add_child(new_element)
			_path_to_elements.static_ui.append(ui.resource_path)
		ElementType.DYNAMIC_UNIT:
			dynamic_unit.add_child(new_element)
			_path_to_elements.dynamic_unit.append(ui.resource_path)
		ElementType.DYNAMIC_MOUSE:
			dynamic_mouse.add_child(new_element)
			_path_to_elements.dynamic_mouse.append(ui.resource_path)
	
	new_element.set("unit", target_unit)
	new_element.set("unit_interface", self)


#func remove_element(ui: NodePath) -> void:
	#var element: Control = get_node_or_null(ui)
	#
	#if not element:
		#return
	#
	#


func clear_ui() -> void:
	var elements_to_free: Array[Node] = get_elements()
	
	for i in elements_to_free:
		i.queue_free()
	
	for i in _path_to_elements:
		i.clear()


func refresh_ui() -> void:
	var elements_to_free: Array[Node] = get_elements()
	
	for i in elements_to_free:
		i.queue_free()
	
	for element_type in _path_to_elements.keys():
		var elements_to_load: Array = _path_to_elements[element_type]
		
		for element in elements_to_load:
			var element_to_instance: PackedScene = load(element)
			
			match element_type:
				"static_ui":
					static_ui.add_child(element_to_instance.instantiate())
				"dynamic_unit":
					dynamic_unit.add_child(element_to_instance.instantiate())
				"dynamic_mouse":
					dynamic_mouse.add_child(element_to_instance.instantiate())



func set_target_unit(unit: Unit) -> void:
	target_unit = unit
	
	for i in get_elements():
		i.set("unit", target_unit)


func get_elements() -> Array[Node]:
	var elements: Array[Node] = []
	
	elements.append_array(static_ui.get_children())
	elements.append_array(dynamic_unit.get_children())
	elements.append_array(dynamic_mouse.get_children())
	
	return elements
