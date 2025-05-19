class_name TransitionListenerSignal
extends TransitionListener

## Listens for a signal from a node owned by [member TransitionListener.entity].
##
## TransitionListenerSignal connects to a signal within a node owned by [member TransitionListener.entity], 
## emitting [signal check_success] when the signal from that node is emitted.

var path_to_node_index: NodePath = ""



func _init(node_path_index: NodePath) -> void:
	path_to_node_index = node_path_index


func _entity_set() -> void:
	var node: Node = get_node_from_entity(JILibrary.get_nodepath_names(path_to_node_index))
	var signal_name: String = path_to_node_index.get_subname(0)
	var call: Callable = JILibrary.get_signal_callable_unbinded(node, signal_name, _on_tracked_signal_emitted)
	
	node.connect(signal_name, call)


func _on_tracked_signal_emitted() -> void:
	check_success.emit()
