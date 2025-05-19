@tool
class_name EntityState
extends TargetInitializer

## A state for [EntityStateMachine].
##
## [EntityState] extends [TargetInitializer], which allows the use of [ConfProperty]s to initialize properties
## when the [EntityState] becomes the current state of an [EntityStateMachine]. 
##[br][br]
## In addition, [EntityState] also contains a customizable list of [TransitionListener]s. 
## Each [TranisitionListener] is paired with a [String] of the name of the [EntityState] that should be 
## transition to next. If an empty [String] is provided at runtime, then that [TransitionListener] is 
## removed to save on memory.

## Emitted when this state is ready to transition to another state.
signal transition_requested(next_state: String)

## Notification received when [member EntityStateMachine.current_state] is set to this state.
const NOTIFICATION_ENTER: int = 0
## Notification received every process frame while [member EntityStateMachine.current_state] is set to this state.
const NOTIFICATION_HANDLE_PROCESS: int = 1
## Notification received every physics frame while [member EntityStateMachine.current_state] is set to this state.
const NOTIFICATION_HANDLE_PHYSICS_PROCESS: int = 2
## Notification received when an unhandled input is received while [member EntityStateMachine.current_state] is set to this state.
const NOTIFICATION_HANDLE_INPUT: int = 3
## Notification received when a collision occurs while [member EntityStateMachine.current_state] is set to this state. 
const NOTIFICATION_HANDLE_COLLISION: int = 4
## Notification received when a timeout occurs while [member EntityStateMachine.current_state] is set to this state.
## Requires that [member timeout_time_in_state] is more than 0.0.
const NOTIFICATION_HANDLE_TIMEOUT: int = 5
## Notification received when [member EntityStateMachine.current_state] is set to another state while
## this state is the current state.
const NOTIFICATION_EXIT: int = 6

## Name of the state. Changing this variable will also change [member Resource.resource_name].
@export var name: String = "":
	set(value):
		name = value
		resource_name = name
## A script extending [EntityStateCustomScript] that provides additional functionality to this state.
@export var custom_script: Script = null:
	set(value):
		if not value.get_global_name() == "EntityStateCustomScript":
			return
		
		custom_script = value
		_custom_script_ref = custom_script.new()
## How long this state will last. If more than 0.0, then a [SceneTreeTimer] will start, calling
## [method _handle_timeout] upon [signal SceneTreeTimer.timeout].
var timeout_time_in_state: float = 0.0
## The state that will be next upon timeout if [member timeout_in_state] is more than 0.0.
var timeout_next_state: String = ""
var _transitions: Dictionary[String, Dictionary] = {}
var entity: Entity = null:
	set(value):
		entity = value
		
		for i in _transitions:
			_transitions[i].listener.entity = entity
## Data added by [EntityStateMachine] to be used by the virtual methods in this class. This is a workaround
## since [Object._notification] cannot accept additional parameters. Cleared when [member NOTIFICATION_EXIT] is received.
var state_machine_data: Dictionary = {
	process_delta = 0.0,
	physics_process_delta = 0.0,
	input = null,
	collision = null
}

var _custom_script_configurable_values: Dictionary[String, Dictionary] = {}
var _timer: SceneTreeTimer = null
var _custom_script_ref: EntityStateCustomScript = null



func _init() -> void:
	resource_local_to_scene = true


func _reset_state() -> void:
	print("reset")
	_transitions = {}


func _notification(what: int) -> void:
	match what:
		NOTIFICATION_POSTINITIALIZE:
			if Engine.is_editor_hint():
				return
			
			for i in _transitions.keys():
				if _transitions[i].next_state.is_empty():
					_transitions.erase(i)
			
			print(_transitions.keys())
		NOTIFICATION_ENTER:
			_enter()
		NOTIFICATION_EXIT:
			_exit()
		NOTIFICATION_HANDLE_PROCESS:
			_handle_process(state_machine_data.process_delta)
			
			for i in _transitions:
				if _transitions[i].listener.call_check_every_process_frame:
					_transitions[i].listener._check()
		NOTIFICATION_HANDLE_PHYSICS_PROCESS:
			_handle_physics_process(state_machine_data.physics_process_delta)
		NOTIFICATION_HANDLE_INPUT:
			_handle_input(state_machine_data.input)
		NOTIFICATION_HANDLE_COLLISION:
			_handle_collision(state_machine_data.collision)
		NOTIFICATION_HANDLE_TIMEOUT:
			_handle_timeout()



func _get_property_list() -> Array[Dictionary]:
	var property_list: Array[Dictionary] = []
	
	property_list.append({
		name = "Transitions",
		type = TYPE_NIL,
		usage = PROPERTY_USAGE_GROUP,
		hint_string = "trans-"
	})
	
	property_list.append({
		name = "trans-timeout/time_in_state",
		type = TYPE_FLOAT
	})
	
	property_list.append({
		name = "trans-timeout/next_state",
		type = TYPE_STRING
	})
	
	for i in _transitions:
		property_list.append({
			name = str("trans-", i),
			type = TYPE_STRING
		})
	
	property_list.append({
		name = "Configurable Values",
		type = TYPE_NIL,
		usage = PROPERTY_USAGE_GROUP,
		hint_string = "conval-"
	})
	
	return property_list


func _set(property: StringName, value: Variant) -> bool:
	if property.begins_with("trans-"):
		var transition_name: String = property.get_slice("-", 1)
		
		if transition_name.begins_with("timeout"):
			if transition_name == "timeout/time_in_state":
				timeout_time_in_state = value
				return true
			
			if transition_name == "timeout/next_state":
				timeout_next_state = value
				return true
		
		if _transitions.get(transition_name):
			_transitions[transition_name].next_state = value
			return true
	
	return false


func _get(property: StringName) -> Variant:
	if property.begins_with("trans-"):
		var transition_name: String = property.get_slice("-", 1)
		
		if transition_name.begins_with("timeout"):
			if transition_name == "timeout/time_in_state":
				return timeout_time_in_state
			
			if transition_name == "timeout/next_state":
				return timeout_next_state
		
		if _transitions.get(transition_name):
			return _transitions[transition_name].next_state
	
	return


func _property_can_revert(property: StringName) -> bool:
	if property.begins_with("trans-"):
		return true
	
	return false


func _property_get_revert(property: StringName) -> Variant:
	if property.begins_with("trans-"):
		if property.ends_with("time_in_state"):
			return 0.0
		
		return ""
	
	return


## Virtual method. See [member NOTIFICATION_ENTER] for more.
func _enter() -> void:
	if custom_script:
		custom_script._enter()
	
	if timeout_time_in_state > 0.0:
		_timer = Engine.get_main_loop().create_timer(timeout_time_in_state, false, true)
		_timer.timeout.connect(_handle_timeout)

## Virtual method. See [member NOTIFICATION_HANDLE_PROCESS] for more.
func _handle_process(delta: float) -> void:
	if custom_script:
		custom_script._handle_process(delta)
	
	for i in _transitions:
		if _transitions[i].listener.call_check_every_frame == true:
			_transitions[i].listener._check()

## Virtual method. See [member NOTIFICATION_HANDLE_PHYSICS_PROCESS] for more.
func _handle_physics_process(delta: float) -> void:
	if custom_script:
		custom_script._handle_physics_process(delta)

## Virtual method. See [member NOTIFICATION_HANDLE_INPUT] for more.
func _handle_input(event: InputEvent) -> void:
	if custom_script:
		custom_script._handle_input(event)

## Virtual method. See [member NOTIFICATION_HANDLE_COLLISION] for more.
func _handle_collision(body: Node) -> void:
	if custom_script:
		custom_script._handle_collision(body)

## Virtual method. See [member NOTIFICATION_HANDLE_TIMEOUT] for more.
func _handle_timeout() -> void:
	if custom_script:
		custom_script._handle_timeout()

## Virtual method. See [member NOTIFICATION_EXIT] for more.
func _exit() -> void:
	if custom_script:
		custom_script._exit()
	
	if _timer:
		_timer.timeout.disconnect(_handle_timeout)
		_timer = null
	
	state_machine_data = {}



func add_input_transition(transition_name: String, type: TransitionListenerInput.EventListenerType, 
			input_group: Array[PackedStringArray]) -> void:
	add_transition(transition_name, TransitionListenerInput.new(input_group, type))


func add_signal_transition(transition_name: String, path_indexed: NodePath) -> void:
	add_transition(transition_name, TransitionListenerSignal.new(path_indexed))


func add_limit_transition(transition_name: String, path_indexed: NodePath, limit: Variant) -> void:
	add_transition(transition_name, TransitionListenerLimit.new(path_indexed, limit))


func add_cost_to_transition(target_transition: String, path_indexed: NodePath, value_cost: Variant) -> void:
	if not _transitions.get(target_transition):
		printerr("%s: attempted to add cost to non-existent transition %s." % [name, target_transition])
		return
	
	var cost_actual = 0.0
	
	#if value_cost is NodePath:
		#if value_cost.begins_with("confprop:"):
			#cost_actual = get_conf_prop_value()
		#else:
			#cost_actual = value_cost
	
	var cost_listener: TransitionListenerCost = TransitionListenerCost.new(_transitions[target_transition].listener, path_indexed, cost_actual)
	add_transition(target_transition, cost_listener)



func add_transition(transition_name: String, transition_listener: TransitionListener) -> void:
	_transitions[transition_name] = {
		listener = transition_listener,
		next_state = ""
	}
	transition_listener.check_success.connect(_on_TransitionListener_check_success.bind(transition_name))
	notify_property_list_changed()



func _on_TransitionListener_check_success(transition_name: String) -> void:
	print(transition_name)
	transition_requested.emit(_transitions[transition_name].next_state)
