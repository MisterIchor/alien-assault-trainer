class_name EntityStateMachine
extends Node

## State machine for [Entity]-derived nodes.

## The state that [EntityStateMachine] is processing. See [EntityState] for more.
var current_state: EntityState = null:
	set = set_current_state
## An [Array] that contains the [EntityState]s that this [EntityStateMachine] has initialized.
var states: Array[EntityState] = []
## Determines whether this state machine is processing [member current_state]. Will not work
## if the state machine has not been initialized.
var active: bool = false:
	set = set_active

## States required for the [EntityStateMachine] to successfully initialize. [member current_state] will
## be set to the first state in this array when [method initialize_states] is called.
var _required_states: PackedStringArray = ["idle"]
var _machine_initialized: bool = false



func _process(delta: float) -> void:
	if current_state:
		current_state.state_machine_data.physics_process_delta = delta
		current_state.notification(EntityState.NOTIFICATION_HANDLE_PROCESS)


func _physics_process(delta: float) -> void:
	if current_state:
		current_state.state_machine_data.physics_process_delta = delta
		current_state.notification(EntityState.NOTIFICATION_HANDLE_PHYSICS_PROCESS)


func _unhandled_input(event: InputEvent) -> void:
	if current_state:
		current_state.state_machine_data.input = event
		current_state.notification(EntityState.NOTIFICATION_HANDLE_INPUT)

## Virtual method for [method get_state]. Overwrite to customize state acquisition behavior. Must
## return an [EntityState].
func _get_state(state_name: String) -> EntityState:
	for i: EntityState in states:
		var file_name: String = (i.get_script() as Script).get_file_name().split(".")[0]
		
		if state_name.matchn(file_name):
			return i
	
	return null

## Virtual method for [method initialize_states]. Called before [method _initialize_states] and is used
## to checks for the state names within [member _required_states]. Must return a [PackedStringArray],
## the array consisting of the names of the required [EntityState]s that were not found.
func _required_states_check(states: Array) -> PackedStringArray:
	var required_states_not_found: Array = _required_states.duplicate()
	
	for i: EntityState in states:
		var idx: float = required_states_not_found.find(i.name)
		
		if not idx == -1:
			required_states_not_found.remove_at(idx)
	
	return required_states_not_found

## Virtual method for [method initialize_states]. Overwrite to customize initialization behavior. Requires 
## that a [bool] value is returned. If true, initialization is a success and [member active] can be set to [param true].
func _initialize_states(states: Array) -> bool:
	for i: EntityState in states:
		i.entity = get_parent()
	
	return true

## Virutal method called when [signal EntityState.transition_finished] is emitted from an initialized
## [EntityState]. Must return a [bool]. If true, the [EntityStateMachine] will transition to the next state.
func _transition_condition_check(next_state: String) -> bool:
	return true

## Virtual method used to edit [param state_name] 
func _transition_parse_string(state_name: String) -> String:
	return state_name

## Starts the state initialization process. For initialization to be successful, [method _required_states_check]
## must return an empty [PackedStringArray] and [method _initialize_states] must return [param true].
##[br][br]
## [b]Note:[/b] This function does nothing if a successful initialization has already been completed.
func initialize_states(states: Array[EntityState]) -> void:
	if _machine_initialized:
		return
	
	print("%s: Checking for required states..." % get_parent().name)
	var states_not_found: PackedStringArray = _required_states_check(states)
	
	if not states_not_found.is_empty():
		printerr("%s: Initialization failed, required states not found: %s." % [get_parent().name, states_not_found])
		return
	
	print("%s: Required states found, initializing states..." % get_parent().name)
	_machine_initialized = _initialize_states(states)
	
	if _machine_initialized:
		print("%s: State initialization complete, lets do this!" % get_parent().name)
		current_state = states.front()




func set_current_state(new_state: EntityState) -> void:
	if current_state:
		current_state.transition_requested.disconnect(_on_transition_requested)
		current_state.notification(EntityState.NOTIFICATION_EXIT)
	
	current_state = new_state
	
	if current_state:
		current_state.transition_requested.connect(_on_transition_requested)
		current_state.notification(EntityState.NOTIFICATION_ENTER)


func set_active(value: bool) -> void:
	if value == true:
		if not _machine_initialized:
			return
	
	active = value
	set_process(active)
	set_physics_process(active)
	set_process_unhandled_input(active)



func get_state(state_name: String) -> EntityState:
	return _get_state(state_name)



func _on_transition_requested(next_state: String) -> void:
	if _transition_condition_check(next_state):
		current_state = get_state(_transition_parse_string(next_state))


func _on_collision(body: Node) -> void:
	if current_state and active:
		current_state._handle_collision(body)
