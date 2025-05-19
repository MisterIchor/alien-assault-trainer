@tool
extends Resource

## State for [UnitStateMachine]. Contains several options for customizing behavior and setting up transitions
## for other states.

enum MovementType {
	## [Unit] movement is inertia-based, gaining speed and slowing down gradually. [Unit] will turn to 
	## face the direction it is moving.
	MOVE_AND_TURN,
	## [Unit] movement is inertia-based, gaining speed and slowing down gradually. [Unit] direction will 
	## remain static.
	MOVE, 
	## [Unit] movement is inertia-based, gaining speed and slowing down gradually. [Unit] will turn to 
	## face in the direction of the pointer.
	MOVE_FACING_POINTER,
	## [Unit] speed is instantly set to their default speed times [member default_speed_mod]. Useful
	## for avoidance-type states such as dodging and diving. [Unit] will turn to face in the direction it
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
signal transition_requested(next_state, prefix)

@export var name: String = "":
	set(value):
		name = value
		resource_name = prefix.capitalize() + name.capitalize()
@export_group("Transitions")
## When transitioning, [UnitStateMachine] will prioritize prioritize states that have this prefix. 
@export var prefix: String = "":
	set(value):
		prefix = value
		resource_name = prefix.capitalize() + name.capitalize()
## How long this state will last. If not -1, will start a timer that will end the state upon timeout,
## transitioning to the state defined in [member on_timeout].
@export var time_in_state: float = -1.0
## State to transition to if the [Unit] starts dodging.
@export_subgroup("Run")
## State to transition to if the [Unit] starts moving.
@export var on_run_start: String = ""
## State to transition to if the [Unit] stops running
@export var on_run_stop: String = ""
## Determines whether the prefix should be ignore if an on_run* transition occurs.
@export var on_run_ignore_prefix: bool = false
@export_subgroup("Aim")
## State to transition to if the [Unit] starts aiming. 
@export var on_aim_start: String = ""
## State to transition to if the [Unit] stops aiming.
@export var on_aim_stop: String = ""
## Determines whether the prefix should be ignored when an on_aim* transition occurs.
@export var on_aim_ignore_prefix: bool = false
@export_subgroup("Sprint")
## State to transition to if the [Unit] starts sprinting.
@export var on_sprint_start: String = ""
## State to transition to if the [Unit] stops sprinting.
@export var on_sprint_stop: String = ""
## Determines whether the prefix should be ignore when an on_sprint* transition occurs.
@export var on_sprint_ignore_prefix: bool = false
@export_subgroup("Dodge")
## State to transition to when the [Unit] starts dodging.
@export var on_dodge: String = ""
## Determites whether the prefix should be ignore when an on_dodge transition occurs.
@export var on_dodge_ignore_prefix: bool = false
@export_subgroup("Timeout")
## State to transition to once the state's timer ends.
@export var on_timeout: String = ""
## Determines whether the prefix should be ignore when an on_timeout transition occurs.
@export var on_timeout_ignore_prefix: bool = false
@export_subgroup("Health")
## State to transition to when the units health is critical or lower.
@export var on_health_critical: String = ""
## State to transition to when the units health is less than or equal to 0.
@export var on_incapacitated: String = ""
## Determines whether the prefix should be ignore when an on_health_critical or on_incapacitated 
## transition occurs.
@export var on_health_ignore_prefix: bool = false
@export_subgroup("Collision")
## State to transition to upon collision when the [[Unit]]'s [method CharacterBody2D.move_and_slide] returns
## true.
@export var on_collision: String = ""
## Determines whether the prefix should be ignored when an on_collision transition occurs.
@export var on_collision_ignore_prefix: bool = false
@export_group("Stats")
@export_subgroup("Health")
## Health cost to enter this state. If there is not enough health to transition to this state, the 
## transition will not occur.
@export var health_cost: float = 0.0
## Percentage of base health regenerated while in this state. If base health is 100 and [member health_regen_cap_mod]
## is 0.8, health will only be regenerated until it equals 80.
@export var health_regen_cap_mod: float = 1.0
## Amount of health regenerated every 0.1 seconds while in this state.
@export var health_regen_rate: float = 0.0
@export_subgroup("Stamina")
## Stamina cost to enter this state. If there is not enough stamina to transition to this state, the
## tranisition will not occur.
@export var stamina_cost: float = 0.0
## Percentage of base stamina regenerated while in this state. If base stamina is 100 and [member stamina_regen_cap_mod]
## is 0.8, stamina will only be regenerated until it reaches 80.
@export var stamina_regen_cap_mod: float = 1.0
## Amount of stamina regenerated every 0.1 seconds while in this state.
@export var stamina_regen_rate: float = 0.5
## Amount of stamina regenerated every 0.1 seconds while moving in this state. If left at -1337, will
## default to [member stamina_regen_rate]
@export var stamina_regen_rate_moving: float = -1337
@export_subgroup("Combat")
## When using a melee weapon, the damage dealt with a successful attack is multiplied by this modifier
## while in this state.
@export var melee_damage_mod: float = 1.0
## When using a ranged weapon, the accuracy is modified by this modifier while in this state.
@export var ranged_accuracy_mod: float = 1.0
@export_group("Movement")
## How movement should be handled while in this state.
@export var movement_type: MovementType = MovementType.MOVE_AND_TURN
## How fast the [Unit] will move in this state, calculated by it's base speed times this modifier.
@export var default_speed_mod: float = 1.0
## If enabled, allows the [Unit] to transition to the move state.
@export_group("Interaction")
## If enabled, allows the [Unit] to pickup items from its surroundings.
@export var allow_pickup: bool = true
## If enabled, allows the [Unit] to drop items from its inventory.
@export var allow_drop: bool = true
## If enabled, allows the [Unit] to interact with its environment.
@export var allow_env_interaction: bool = true
## if enabled, allows the [Unit] to use any item that is has currently equipped.
@export var allow_equipped_item_interaction: bool = true
@export_group("Animation")
## Head facing behavior while in this state.
@export var head_look_at: HeadLookAt = HeadLookAt.NORMAL
## Controls turn speed of individual sections of body.
@export var body_procedural_speed: Dictionary = {
	head = 0.15,
	body_upper = 0.12,
	body_lower = 0.09
}
## Animation to play upon entering this state.
@export var animation_to_play: Animation
@export_group("Custom")
## When assigned with a script extending [UnitStateCustomScript], allows the user to customize the state
## outside of the scope of what's provide through the exported variables.
@export var custom_script: GDScript = null
## Exported variables from [member custom_script] that can be changed to affect the behavior of [member custom script].
@export var configurable_values: Dictionary = {}

## The [Unit] that this state is assigned to.
var unit: Unit = null
var _custom_script_node: UnitStateCustomScript = null
var _timer: SceneTreeTimer = null
var _movement:= Vector2()
var _is_updating_movement:= true



func _init() -> void:
	resource_local_to_scene = true



func _handle_transition() -> void:
	if on_run_start:
		if _movement:
			_finished(on_run_start, on_run_ignore_prefix)
			return
	
	if on_run_stop:
		if not _movement:
			_finished(on_run_stop, on_run_ignore_prefix)
			return
	
	if on_aim_start:
		if Input.is_action_pressed("aim"):
			_finished(on_aim_start, on_aim_ignore_prefix)
			return
	
	if on_aim_stop:
		if not Input.is_action_pressed("aim"):
			_finished(on_aim_stop, on_aim_ignore_prefix)
			return
	
	if on_sprint_start:
		if Input.is_action_pressed("sprint"):
			_finished(on_sprint_start, on_sprint_ignore_prefix)
			return
	
	if on_sprint_stop:
		if not Input.is_action_pressed("sprint"):
			_finished(on_sprint_stop, on_sprint_ignore_prefix)
			return
	
	if on_dodge:
		if Input.is_action_pressed("dodge"):
			_finished(on_dodge, on_dodge_ignore_prefix)
			return


func _finished(next_state: String, ignore_prefix: bool) -> void:
	transition_requested.emit(next_state, prefix if not ignore_prefix else "")



func _enter() -> void:
	if not time_in_state == -1.0:
		_timer = Engine.get_main_loop().create_timer(time_in_state, false, true)
		_timer.timeout.connect(_handle_timeout)
	
	if custom_script:
		if not _custom_script_node._enter():
			return
	
	unit.health.regen_rate = health_regen_rate
	unit.stamina.regen_rate = stamina_regen_rate
	unit.stamina.stamina_current -= stamina_cost
	unit.combat.ranged_accuracy_modifier = ranged_accuracy_mod
	unit.combat.melee_damage_modifier = melee_damage_mod
	unit.body.procedural_anim_speed = body_procedural_speed
	
	match movement_type:
		MovementType.LAUNCH, MovementType.LAUNCH_AND_TURN:
			_is_updating_movement = false
			_movement = unit.movement.get_movement_inputs()
		MovementType.MOVE, MovementType.MOVE_AND_TURN, MovementType.MOVE_FACING_POINTER:
			_is_updating_movement = true



func _handle_process(delta: float) -> void:
	if _is_updating_movement:
		_movement = unit.movement.get_movement_inputs()
	
	if custom_script:
		if not _custom_script_node._handle_process(delta):
			return
	
	if on_health_critical:
		if unit.health.health_current <= unit.health.get_health_critical():
			_finished(on_health_critical, on_health_ignore_prefix)
			return
	
	if on_incapacitated:
		if unit.health.health_current <= 0:
			_finished(on_incapacitated, on_health_ignore_prefix)
			return
	
	if not stamina_regen_rate_moving == -1337:
		if _movement:
			unit.stamina.regen_rate = stamina_regen_rate_moving
		else:
			unit.stamina.regen_rate = stamina_regen_rate
	
	match head_look_at:
		HeadLookAt.NORMAL:
			unit.body.head_look_at = Vector2()
		HeadLookAt.POINT_OF_INTEREST:
			if not unit.get_closest_poi():
				unit.body.head_look_at = Vector2()
			else:
				unit.body.head_look_at = unit.to_local(unit.get_closest_poi().global_position)
	
	_handle_transition()


func _handle_physics_process(delta: float) -> void:
	if custom_script:
		if not _custom_script_node._handle_physics_process(delta):
			return
	
	match movement_type:
		MovementType.MOVE_AND_TURN:
			unit.movement.move_and_turn(_movement, default_speed_mod)
		MovementType.MOVE:
			unit.movement.move(_movement, default_speed_mod)
		MovementType.MOVE_FACING_POINTER:
			unit.movement.move(_movement, default_speed_mod)
			unit.movement.look(unit.get_local_mouse_position())
		MovementType.LAUNCH_AND_TURN:
			unit.movement.launch_and_turn(_movement, default_speed_mod)
		MovementType.LAUNCH:
			unit.movement.launch(_movement, default_speed_mod)


func _handle_input(event: InputEvent) -> void:
	if custom_script:
		if not _custom_script_node._handle_input(event):
			return
	
	if allow_equipped_item_interaction:
		if event.is_action_pressed("primary"):
			unit.use_equipped_item("primary")
		
		if event.is_action_pressed("secondary"):
			unit.use_equipped_item("secondary")
		
		if event.is_action_pressed("reload"):
			unit.use_equipped_item("reload")
	
	if allow_env_interaction:
		if event.is_action_pressed("env_interaction"):
			unit.pickup()
	
	if allow_drop:
		if event.is_action_pressed("drop_equipped_item"):
			unit.inventory.drop_equipped_item()
	
	var switch_inputs: Array[bool] = [
		event.is_action_pressed("item_1"),
		event.is_action_pressed("item_2"),
		event.is_action_pressed("item_3"),
		event.is_action_pressed("item_4"),
		event.is_action_pressed("item_5"),
	]
	
	for i in switch_inputs.size():
		if switch_inputs[i]:
			unit.switch_item(i)


func _handle_collision(body: Node) -> void:
	if on_collision:
		_finished(on_collision, false)


func _handle_timeout() -> void:
	if custom_script:
		if not _custom_script_node._handle_timeout():
			return
	
	if on_timeout:
		_finished(on_timeout, on_timeout_ignore_prefix)


func _exit() -> void:
	if custom_script:
		if not _custom_script_node._exit():
			return
	
	if _timer:
		_timer.timeout.disconnect(_handle_timeout)
