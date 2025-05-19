class_name EntityStateCustomScript
extends RefCounted

## A script that can be set to [member EntityState.custom_script] to add additional functionality within
## a state. Intended for modding purposes.

## The [Entity] that this state is handling. Set when initialized through [method EntityStateMachine.initialize_states].
var entity: Entity = null
var _timer: SceneTreeTimer = null


## Called when [member EntityStateMachine.current_state] is set to this state.
func _enter() -> void:
	return

## Called every processs frame when [member EntityStateMachine.current_state] is set to this state.
func _handle_process(delta: float) -> void:
	return

## Called every physics frame when [member EntityStateMachine.current_state] is set to this state.
func _handle_physics_process(delta: float) -> void:
	return

## Called when an unhandled [InputEvent] occurs while [member EntityStateMachine.current_state] is set to this state.
func _handle_input(event: InputEvent) -> void:
	return

## Called when a collision occurs while [member EntityStateMachine.current_state] is set to this state.
##[br][br]
## [b]Note:[/b] Do not connect any collision type signals from [member Entity.body] to this method. 
## [Entity] handles these connections when [member Entity.body] is set.
func _handle_collision(body: Node) -> void:
	return

## Called when the [SceneTreeTimer] created from [method start_timer] times out.
##[br][br]
## [b]Note:[/b] If [method request_transition] is called while there is an active [SceneTreeTimer], 
## the [SceneTreeTimer] will be invalidated and thus any behavior handled under [method _handle_timeout]
## will not be processed.
func _handle_timeout() -> void:
	return

## Called when [member EntityStateMachine.current_state] is set to a new [EntityState] while this state is
## is active.
func _exit() -> void:
	return
