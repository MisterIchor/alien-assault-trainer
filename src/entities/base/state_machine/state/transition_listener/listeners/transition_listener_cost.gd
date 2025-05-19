class_name TransitionListenerCost
extends TransitionListener

## Listens to another [TransitionListener], emitting [signal TransitionListener.check_success] if the
## conditions for that [TransitionListener] is met and if the variable provided through [member path_to_node_index]
## can take the cost of [member value_cost]. 

var listener: TransitionListener = null
var path_to_node_index: NodePath = ""
## The cost to successfully complete a check. This can be an [int], [float], or [NodePath].
var value_cost: Variant = 0.0
var _node: Node = null



func _init(target_listener: TransitionListener, node_path_index: NodePath, cost: Variant) -> void:
	listener = target_listener
	path_to_node_index = node_path_index
	value_cost = cost



func _entity_set() -> void:
	_node = get_node_from_entity(JILibrary.get_nodepath_names(path_to_node_index))
	
	if _node:
		for i in listener.check_success.get_connections():
			if not i.callable.get_object() is EntityState:
				listener.check_success.disconnect(i.callable)
		
		listener.check_success.connect(_on_TargetListener_check_success)


func _on_TargetListener_check_success() -> void:
	var node_value: float = _node.get(path_to_node_index.get_concatenated_subnames())
	var cost_actual: float = 0.0
	
	if value_cost is NodePath:
		var indexed: Variant = find_in_entity(value_cost)
		
		if indexed is Callable:
			cost_actual = indexed.call()
		else:
			cost_actual = indexed
	else:
		cost_actual = value_cost
	
	if node_value >= cost_actual:
		_node.set(path_to_node_index.get_concatenated_subnames(), node_value - cost_actual)
		check_success.emit()
