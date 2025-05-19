class_name TransitionListenerLimit
extends TransitionListener

## Listens to a float/int variable to see if it drops below [member value_limit].

var path_to_node_index: String = ""
## Value used as the limit. If the variable within [member path_to_node_index] is less than or equal to
## this value, then [signal TransitionListener.check_success] will be emitted. Can be an [int], [float], or
## [NodePath] pointing to a property or method that will return either of the two types.
var value_limit: Variant = 0.0



func _init(node_path_index: String, limit: Variant) -> void:
	path_to_node_index = node_path_index
	value_limit = limit


func _check() -> void:
	var node_value: float = get_value_from_entity(path_to_node_index)
	var limit_actual: float = 0.0
	
	if value_limit is NodePath:
		var indexed: Variant = find_in_entity(value_limit)
		
		if indexed is Callable:
			limit_actual = indexed.call()
		else:
			limit_actual = indexed
	else:
		limit_actual = value_limit
	
	if node_value <= limit_actual:
		check_success.emit()


func _entity_set() -> void:
	if get_node_from_entity(JILibrary.get_nodepath_names(path_to_node_index)):
		call_check_every_process_frame = true
