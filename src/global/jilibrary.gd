class_name JILibrary
extends Object

## A global library consisting of static functions.


## Returns a value from [param dict] using an index instead of a key, similar to an [Array].
static func get_from_dictionary_index(dict: Dictionary, idx: int) -> Variant:
	if dict.is_empty():
		return null
	
	return dict[dict.keys()[idx]]


static func convert_enum_keys_to_string(enumerator: Dictionary) -> String:
	if not is_potential_enum(enumerator):
		return ""
	
	var keys_string: PackedStringArray = []
	
	for i in enumerator.keys():
		keys_string.append(str(i, ":", enumerator[i]))
	
	return ",".join(keys_string)


## Returns [param signal_callable] with its original arguments removed. This allows for a signal with arguments 
## to connect to a method without arguments. Requires that the [param object] has [param signal_name] defined.
static func get_signal_callable_unbinded(object_with_signal: Object, signal_name: String, signal_callable: Callable) -> Callable:
	var argument_count: int = -1
	
	for i in object_with_signal.get_signal_list():
		if i.name == signal_name:
			argument_count = i.args.size()
			break
	
	if argument_count > 0:
		return signal_callable.unbind(argument_count)
	
	return signal_callable

## Returns true if two properties are the same type.
static func is_same_type(value_one: Variant, value_two: Variant) -> bool:
	return typeof(value_one) == typeof(value_two)

## Searches a node for a property, method, or signal in that order. Returns the property's value,
## method (as a [Callable]), or signal (as a [Signal]). Returns [code]null[/code] if nothing is found.
static func find_in_node(target: Node, path_indexed: NodePath) -> Variant:
	var node_to_search: Node = get_node_from_node(target, get_nodepath_names(path_indexed))
	var index: NodePath = get_nodepath_subnames(path_indexed)
	
	if not node_to_search:
		return
	
	if node_to_search.get_indexed(index):
		return node_to_search.get_indexed(index)
	
	if node_to_search.has_method(index.get_subname(0)):
		return Callable(node_to_search, index.get_subname(0))
	
	if node_to_search.has_signal(index.get_subname(0)):
		return Signal(node_to_search, index.get_subname(0))
	
	return


## Returns a copy of [param path_indexed] with the subnames trundicated, leaving a path to a node.
static func get_nodepath_names(path_indexed: NodePath) -> NodePath:
	return path_indexed.slice(0, path_indexed.get_name_count())

## Returns a copy of [param path_indexed] with the names trundicated, leaving a path to a property.
static func get_nodepath_subnames(path_indexed: NodePath) -> NodePath:
	return path_indexed.slice(path_indexed.get_name_count()).get_as_property_path()

## Returns the node located at [param path]. [param path] is a relative [NodePath] to 
## [param target]. 
##[br][br]
## Returns null if no node is found or if [method is_node_from_target] is [code]false[/code].
static func get_node_from_node(target: Node, path: NodePath) -> Node:
	var desired_node: Node = target.get_node_or_null(path)
	
	if not desired_node:
		return null
	
	if not is_node_from_target(target, desired_node):
		return null
	
	return desired_node

## Returns the value located at [param path_indexed]. [param path_indexed] is a relative indexed [NodePath] to [param target].
##[br][br]
## Return [code]null[/code] if the property in [param path_indexed] does not exist or if [method is_node_from_target]
## return [code]false[/code].
static func get_value_from_node(target: Node, path_indexed: NodePath) -> Variant:
	var node: Node = get_node_from_node(target, get_nodepath_names(path_indexed))
	
	if not node:
		return
	
	return node.get_indexed(get_nodepath_subnames(path_indexed))

## Returns the method located at [param path_indexed] as a [Callable]. [param path_indexed] is a relative
## indexed [NodePath] to [param target]. 
##[br][br]
## Returns an empty [Callable] if the node located in [param path_indexed]
## does not exist, does not have the method requested, or if [method is_node_from_target] returns [code]false[/code].
static func get_callable_from_node(target: Node, path_indexed: NodePath) -> Callable:
	var node: Node = get_node_from_node(target, get_nodepath_names(path_indexed))
	var method_name: String = path_indexed.get_subname(0)
	
	if not node:
		return Callable()
	
	if not node.has_method(method_name):
		return Callable()
	
	return Callable(node, method_name)

## Returns the signal located at [param path_indexed] as a [Signal]. [param path_indexed] is a relative indexed
## [NodePath] to [param target].
##[br][br]
## Returns an empty [Signal] if the node located at [param path_indexed] does not exist, does not have the signal
## requested, or if [method is_node_from_target] returns [code]false[/code].
static func get_signal_from_node(target: Node, path_indexed: NodePath) -> Signal:
	var node: Node = get_node_from_node(target, get_nodepath_names(path_indexed))
	var signal_name: String = path_indexed.get_subname(0)
	
	if not node:
		return Signal()
	
	if not node.has_signal(signal_name):
		return Signal()
	
	return Signal(node, signal_name)

## Returns [code]true[/code] if the [param node] is the child of, is owned by [param target], or is [param target].
static func is_node_from_target(target: Node, node: Node) -> bool:
	if target == node:
		return true
	
	if node.get_parent():
		if node.get_parent() == target:
			return true
	
	if node.owner == target:
		return true
	
	return false

## Returns true if [param value] is [Dictionary][[String]][[int]] or if all keys are [String]s
## and all values are [int]s.
##[br][br]
## Without this method, there's no way to check if a dictionary is an enum.
static func is_potential_enum(value: Dictionary) -> bool:
	var typed: Dictionary[String, bool] = {
		keys = value.get_typed_key_builtin() == TYPE_STRING,
		values = value.get_typed_value_builtin() == TYPE_INT
	}
	
	if typed.keys == false:
		for i in value.keys():
			typed.keys = typeof(i) == TYPE_STRING
			
			if typed.keys == false:
				break
	
	if typed.values == false:
		for i in value:
			typed.values = typeof(value[i]) == TYPE_INT
			
			if typed.values == false:
				break
	
	return typed.keys == true and typed.values == true
