class_name TransitionListener
extends RefCounted

## Abstract class to define transitions within [EntityState].
##
## Alone, this class does nothing. Use [TransitionListenerInput], [TransitionListenerSignal]
## if transitions are desired within [EntityState].

## Emitted when conditions for a transition are met.
signal check_success
## The [Entity] that this [TransitionListener] is listening to. Set when an [EntityState] is initialized by
## an [EntityStateMachine] and can be used by scripts extending [TransitionListener].
var entity: Entity = null:
	set(value):
		entity = value
		_entity_set()
## If true, calls [method _check] on every process frame.
var call_check_every_process_frame: bool = false

## Virtual method to determine the conditions for a transition.
func _check() -> void:
	return

## Virtual method called when [member entity] is set.
func _entity_set() -> void:
	return


## Searches the node for the property, method, or signal defined within [param path_indexed] in that
## order. Prints an error and returns [param null] is nothing is found.
##[br][br]
## [b]Note:[/b] This is slower than using the get_*_from_entity methods. Consider using those instead or
## caching the return value of this method.
func find_in_entity(path_indexed: NodePath) -> Variant:
	return JILibrary.find_in_node(entity, path_indexed)


## Returns a node from [param path]. Returns null if the node is not found or if the entity does not own
## the node.
func get_node_from_entity(path: NodePath) -> Node:
	return JILibrary.get_node_from_node(entity, path)

## Returns a value from a property within [member entity].
func get_value_from_entity(path_indexed: NodePath) -> Variant:
	return JILibrary.get_value_from_node(entity, path_indexed)

## Returns a [Callable] with the method from the node defined in [param path_indexed].
func get_callable_from_entity(path_indexed: NodePath) -> Callable:
	return JILibrary.get_callable_from_node(entity, path_indexed)

## Returns a [Signal] from the node defined within [param path_indexed].
func get_signal_from_entity(path_indexed: NodePath) -> Signal:
	return JILibrary.get_signal_from_node(entity, path_indexed) 
