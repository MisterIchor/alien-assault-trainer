@tool
class_name UnitState
extends EntityState

enum MovementType {
	## [entity] movement is inertia-based, gaining speed and slowing down gradually. [entity] will turn to 
	## face the direction it is moving.
	MOVE_AND_TURN,
	## [entity] movement is inertia-based, gaining speed and slowing down gradually. [entity] direction will 
	## remain static.
	MOVE, 
	## [entity] movement is inertia-based, gaining speed and slowing down gradually. [entity] will turn to 
	## face in the direction of the pointer.
	MOVE_FACING_POINTER,
	## [entity] speed is instantly set to their default speed times [member default_speed_mod]. Useful
	## for avoidance-type states such as dodging and diving. [entity] will turn to face in the direction it
	## is moving.
	LAUNCH_AND_TURN,
	## Player speed is instantly set to their default speed times [member default_speed_mod]. Useful
	## for avoidance-type states such as dodging and diving.
	LAUNCH
}
enum HeadLookAt {
	## Head will turn with the look angle.
	NORMAL,
	## Head will turn to look at any nearby points of interest.
	## [br][br]
	## [b]Note:[/b] When [member movement_type] is set to [member MovementType.MOVE_FACING_POINTER], the 
	## point of interest will be the pointer's position.
	POINT_OF_INTEREST
}

var _movement: Vector2 = Vector2()
var _is_updating_movement: bool = false

func _init() -> void:
	add_configurable_value("health/cost_to_enter_state", "static", 0.0)
	add_configurable_value("health/regen_cap_mod", "Health:regen_cap_mod", 1.0)
	add_configurable_value("health/regen_rate", "Health:regen_rate", 0.0)
	add_configurable_value("stamina/cost_to_enter_state", "static", 0.0)
	add_configurable_value("stamina/regen_cap_mod", "Stamina:regen_cap_mod", 1.0)
	add_configurable_value("stamina/regen_rate", "static", 0.5)
	add_configurable_value("stamina/regen_rate_moving", "static", -1337.0)
	add_configurable_value("combat/melee_damage_mod", "Combat:melee_damage_modifier", 1.0)
	add_configurable_value("combat/ranged_accuracy_mod", "Combat:ranged_accuracy_mod", 1.0)
	add_configurable_value("movement/type", "self_enum:MovementType", 0)
	add_configurable_value("movement/default_speed_mod", "static", 1.0)
	add_configurable_value("interaction/allow_pickup", "static", true)
	add_configurable_value("interaction/allow_drop", "static", true)
	add_configurable_value("interaction/allow_env_interaction", "static", true)
	add_configurable_value("interaction/allow_equipped_item_interaction", "static", true)
	add_configurable_value("animation/head_look_at", "self_enum:HeadLookAt", 0)
	add_configurable_value("animation/body_procedural_speed", "UnitBody/VisualBody/procedural_anim_speed", {
		head = 1.0,
		body_upper = 1.0,
		body_lower = 1.0,
	})
	add_configurable_value("animation/animation_to_play", "static", null)
	
	add_input_transition("run/start", TransitionListenerInput.EventListenerType.PRESSED, [["move_up", "move_down", "move_left", "move_right"]])
	add_input_transition("run/stop", TransitionListenerInput.EventListenerType.NOT_PRESSED, [["move_up", "move_down", "move_left", "move_right"]])
	add_input_transition("sprint/start", TransitionListenerInput.EventListenerType.PRESSED, [["move_up", "move_down", "move_left", "move_right"], ["sprint"]])
	add_input_transition("sprint/stop", TransitionListenerInput.EventListenerType.NOT_PRESSED, [["move_up", "move_down", "move_left", "move_right"], ["sprint"]])
	add_input_transition("aim/start", TransitionListenerInput.EventListenerType.PRESSED, [["aim"]])
	add_input_transition("aim/stop", TransitionListenerInput.EventListenerType.NOT_PRESSED, [["aim"]])
	add_input_transition("dodge/start", TransitionListenerInput.EventListenerType.PRESSED, [["move_up", "move_down", "move_left", "move_right"], ["dodge"]])
	add_cost_to_transition("dodge/start", "Stamina:stamina_current", "conval:stamina/stamina_cost")
	add_signal_transition("collision/collided", ".:body_entered")
	add_limit_transition("health/critical", "Health:health_current", "Health:get_health_critical")
	add_limit_transition("health/incapacitated", "Health:health_current", "Health:get_health_incapacitated")



func _enter() -> void:
	match get_configurable_value("movement/type"):
		MovementType.LAUNCH, MovementType.LAUNCH_AND_TURN:
			_is_updating_movement = false
			_movement = entity.movement.get_movement_inputs()
		MovementType.MOVE, MovementType.MOVE_AND_TURN, MovementType.MOVE_FACING_POINTER:
			_is_updating_movement = true



func _handle_process(delta: float) -> void:
	if _is_updating_movement:
		_movement = entity.movement.get_movement_inputs()
	
	match get_configurable_value("animation/head_look_at"):
		HeadLookAt.NORMAL:
			entity.body.head_look_at = Vector2()
		HeadLookAt.POINT_OF_INTEREST:
			if not entity.get_closest_poi():
				entity.visual_body.head_look_at = Vector2()
			else:
				entity.visual_body.head_look_at = entity.to_local(entity.get_closest_poi().global_position)
	


func _handle_physics_process(delta: float) -> void:
	if not get_configurable_value("stamina/regen_rate_moving") == -1337:
		if _movement:
			entity.stamina.stamina_rate = get_configurable_value("stamina/regen_rate_moving")
		else:
			entity.stamina.stamina_rate = get_configurable_value("stamina/regen_rate")
	
	match get_configurable_value("movement/type"):
		MovementType.MOVE_AND_TURN:
			entity.movement.move_and_turn(_movement, get_configurable_value("movement/default_speed_mod"))
		MovementType.MOVE:
			entity.movement.move(_movement, get_configurable_value("movement/default_speed_mod"))
		MovementType.MOVE_FACING_POINTER:
			entity.movement.move(_movement, get_configurable_value("movement/default_speed_mod"))
			entity.movement.look(entity.get_local_mouse_position())
		MovementType.LAUNCH_AND_TURN:
			entity.movement.launch_and_turn(_movement, get_configurable_value("movement/default_speed_mod"))
		MovementType.LAUNCH:
			entity.movement.launch(_movement, get_configurable_value("movement/default_speed_mod"))


func _handle_input(event: InputEvent) -> void:
	if get_configurable_value("interaction/allow_equipped_item_interaction"):
		if event.is_action_pressed("primary"):
			entity.use_equipped_item("primary")
		
		if event.is_action_pressed("secondary"):
			entity.use_equipped_item("secondary")
		
		if event.is_action_pressed("reload"):
			entity.use_equipped_item("reload")
	
	if get_configurable_value("interaction/allow_pickup"):
		if event.is_action_pressed("env_interaction"):
			entity.pickup()
	
	if get_configurable_value("interaction/allow_drop"):
		if event.is_action_pressed("drop_equipped_item"):
			entity.inventory.drop_equipped_item()
	
	var switch_inputs: Array[bool] = [
		event.is_action_pressed("item_1"),
		event.is_action_pressed("item_2"),
		event.is_action_pressed("item_3"),
		event.is_action_pressed("item_4"),
		event.is_action_pressed("item_5"),
	]
	
	for i in switch_inputs.size():
		if switch_inputs[i]:
			entity.switch_item(i)
