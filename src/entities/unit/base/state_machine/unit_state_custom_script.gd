class_name UnitStateCustomScript
extends RefCounted

## An optional object used by [UnitState] that allows for more extensive customization beyond the scope 
## found in exported variables of [UnitState].
##
## Unlike [UnitState], the virtual functions found in [UnitStateCustomScript] must return a boolean value.
## This value determines whether that function should propegate to the [UnitState] it is a child of. 
## For example, if [method _enter] returns false, the rest of [method UnitState._enter] won't process,
## effectively bypassing any settings set with the exported variables of [UnitState].

## Emitted when this state is finished, causing [UnitStateMachine] to switch to the state defined in 
## [param next_state].
signal transition_requested(next_state: String, prefix: String)
## The [Unit] this state is assigned to. [member unit] is set when this state is added to [member UnitStateMachine.states].
var unit: Unit = null


## Called when [member UnitStateMachine.current_state] is set to this state.
func _enter() -> bool:
	return true

## Called every process frame when [member UnitStateMachine.current_state] is set to this state.
func _handle_process(delta: float) -> bool:
	return true

## Called every physics frame when [member UnitStateMachine.current_state] is set to this state.
func _handle_physics_process(delta: float) -> bool:
	return true

## Called when an unhandled input occurs while [member UnitStateMachine.current_state] is set to this state.
func _handle_input(event: InputEvent) -> bool:
	return true

## Called when [member unit]'s [signal Unit.unit_collided_with] is emitted while [member UnitStateMachine.current_state]
## is set to this state.
func _handle_collision(body: Node) -> bool:
	return true

## Called when the timer created by [member UnitState.time_in_state] time's out while [member UnitStateMachine.current_state]
## is set to this state.
func _handle_timeout() -> bool:
	return true

## Called when [UnitStateMachine] switches to another state while this state is active.
func _exit() -> bool:
	return true
