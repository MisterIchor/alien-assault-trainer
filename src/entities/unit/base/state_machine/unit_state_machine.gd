class_name UnitStateMachine
extends EntityStateMachine



func set_state(new_state: UnitState) -> void:
	if current_state:
		current_state.transition_requested.disconnect(_on_transition_requested)
		current_state.unit.unit_collided_with.disconnect(current_state._handle_collision)
		current_state._exit()
	
	current_state = new_state
	
	if current_state:
		current_state.transition_requested.connect(_on_transition_requested)
		current_state.unit.unit_collided_with.connect(current_state._handle_collision)
		current_state._enter()


func set_active(value: bool) -> void:
	if value == true:
		if not get_state("idle"):
			return
	
	active = value
	set_process(active)
	set_physics_process(active)
	set_process_unhandled_input(active)



func get_state(state_name: String) -> UnitState:
	for i in states:
		if state_name.matchn(i.resource_name):
			return i
	
	return null



func _on_unit_collided_with(body: Node) -> void:
	if current_state:
		current_state._handle_collision(body)


#func _on_transition_requested(next_state: String) -> void:
	#for i in states:
		#if i.resource_name.matchn(prefix + next_state):
			#current_state = i
			#return
	#
	#printerr(str(get_parent().name, ": could not find ", prefix, next_state,
				#", transitioning to state without prefix..."))
	#
	#for i in states:
		#if i.name.matchn(next_state):
			#current_state = i
			#print(str(get_parent().name, ": found ", next_state, " without prefix ", prefix,"."))
			#return
	#
	#printerr(get_parent().name, ": could not find ", next_state,".")
