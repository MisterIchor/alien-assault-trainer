@tool
class_name TargetInitializer
extends Resource

## A [Resource] that acts as an intializer for a target [Node].
##
## [TargetInitializer] allows a [Resource] to initialize the values of an [Node] through
## the use of [ConfProperty], which avoids the problem of constantly writing code for the purpose of setting
## templates and makes setting states with unique values easier.
##[br][br]
## Each [ConfProperty] is sorted into categories, which are then displayed in the 
## inspector for easy configuration. [ConfProperty] keeps track of default values and can return
## a copy of itself as a [PropertyRef]. See [ConfProperty] for more
##[br][br]
## [b]Important:[/b] As [TargetInitializer] has no way of validating [NodePath]s while in
## the editor, it is imperitive to test changes before commiting.

## Emits when [member target] is set to a valid [Node].
signal target_set

## The [Node] this [TargetInitializer] is initializing. When calling [method add_configurable_property],
## the [NodePath] from [param path_indexed] is considered relative to [Node].
var target: Node = null:
	set(value):
		target = value
		
		if is_instance_valid(target):
			target_set.emit()
var _configurable_properties: Dictionary[String, Array] = {}



# Making custom exports through code is an ugly, yet addicting process to go through.
# It'd be better without the nested dictionaries, though.
func _get_property_list() -> Array[Dictionary]:
	var property_list: Array[Dictionary] = []
	
	for category: String in _configurable_properties:
		property_list.append({
			name = category,
			type = TYPE_NIL,
			usage = PROPERTY_USAGE_GROUP,
			hint_string = str("%", category, "-")
		})
		
		for property_dict: Dictionary in _configurable_properties[category]:
			var conf_property: ConfProperty = property_dict.conf_property
			var exported_property: Dictionary = {}
			exported_property.name = _get_formatted_string(category, property_dict.editor_name)
			
			if conf_property.is_default_enum():
				var default_dict: Dictionary = conf_property.get_value_default()
				var enum_string: PackedStringArray = []
				
				for i: String in default_dict:
					enum_string.append(str(i.capitalize(), ":", default_dict[i]))
				
				exported_property.type = TYPE_INT
				exported_property.hint = PROPERTY_HINT_ENUM
				exported_property.hint_string = ",".join(enum_string)
				property_list.append(exported_property)
				
				if not conf_property.get_value():
					conf_property.update_value(JILibrary.get_from_dictionary_index(default_dict, 0))
				
				continue
			
			if not conf_property.get_value():
				conf_property.update_value_to_default()
			
			exported_property.type = typeof(conf_property.get_value_default())
			property_list.append(exported_property)
	
	return property_list


func _set(property: StringName, value: Variant) -> bool:
	if property.begins_with("%"):
		if not Engine.is_editor_hint() and not target:
			await target_set
		
		var decompiled_string: PackedStringArray = _get_decompiled_string(property)
		var conf_property: ConfProperty = _get_conf_property(decompiled_string[0], decompiled_string[1])
		
		if conf_property:
			conf_property.update_value(value)
			return true
	
	return false


func _get(property: StringName) -> Variant:
	if property.begins_with("%"):
		if not Engine.is_editor_hint() and not target:
			await target_set
		
		var decomplied_string: Array = _get_decompiled_string(property)
		var conf_property: ConfProperty = _get_conf_property(decomplied_string[0], decomplied_string[1])
		
		if conf_property:
			return conf_property.get_value()
	
	return


func _property_can_revert(property: StringName) -> bool:
	if property.begins_with("%"):
		var decompiled_string: PackedStringArray = _get_decompiled_string(property)
		
		if category_has_property(decompiled_string[0], decompiled_string[1]):
			return true
	
	return false


func _property_get_revert(property: StringName) -> Variant:
	if property.begins_with("%"):
		var decompiled_string: PackedStringArray = _get_decompiled_string(property)
		var conf_property: ConfProperty = _get_conf_property(decompiled_string[0], decompiled_string[1])
		
		if conf_property:
			var default_value: Variant = conf_property.get_value_default()
			
			if conf_property.is_default_enum():
				return JILibrary.get_from_dictionary_index(default_value, 0)
			
			return default_value
	
	return


# Returns a formatted string for use with the inspector.
func _get_formatted_string(category_name: String, editor_name: String) -> String:
	return str("%", category_name, "-", editor_name)


# Returns a decompiled string that was formatted by _get_formatted_string.
func _get_decompiled_string(editor_name: String) -> PackedStringArray:
	var string_array: PackedStringArray = editor_name.split("-")
	string_array[0] = string_array[0].erase(0)
	return string_array


# Used by add_catagory to get an object based on the format of path_indexed.
func _get_object(path_indexed: NodePath) -> Object:
	if path_indexed.get_concatenated_names() == "self":
		return self
	
	if path_indexed.get_concatenated_names().begins_with("%"):
		var category: String = path_indexed.get_concatenated_names().erase(0)
		return _get_conf_property(category, path_indexed)
	
	return JILibrary.get_node_from_node(target, JILibrary.get_nodepath_names(path_indexed))


# Used by get_conf_prop_*, _get_object, _set, _get, and _property_get_revert to
# get a value from a ConfProperty.
func _get_conf_property(category_name: String, search: String) -> ConfProperty:
	if not has_category(category_name):
		return null
	
	var category_array: Array = _configurable_properties[category_name]
	
	for property: Dictionary in category_array:
		if search.matchn(property.editor_name):
			return property.conf_property
	
	for property: Dictionary in category_array:
		if search.matchn(String(property.path)):
			return property.conf_property
	
	return null



## Adds a category to the inspector. Returns [const ERR_ALREADY_EXISTS] if [param category_name] already exists.
func add_category(category_name: String) -> Error:
	if category_name in _configurable_properties:
		print("TargetInitializer: category %s already initialized.")
		return ERR_ALREADY_EXISTS
	
	_configurable_properties[category_name] = []
	notify_property_list_changed()
	return OK


## Creates a [ConfProperty] with the node and property from [param path_indexed]. Will be in
## the inspector under the group of [param category_name], with the name of [param editor_name]. The [NodePath] provided to
## [param path_indexed] must be relative to [member target] and must point to a node that is a child of or is owned by
## [member target]. If [member target] is not set, it will await [signal target_set]
##[br][br]
## Returns [constant ERR_CANT_CREATE] if [param category_name] hasn't been initialized (via [method add_category]) or if
## [method JILibrary.is_node_from_target] returns [code]false[/code]. Will always be successful when [method Engine.is_editor_hint]
## is [code]true[/code].
##[br][br]
## If [param default_is_enum] is true, then assigning a [Dictionary][[String], [int]] to [param default_value]
## exports a list of options to choose from similar to exporting an enum via [annotation @GDScript.@export]. 
## The default value in this case will always be the first value in the dictionary.
##[br][br]
## [b]Note:[/b] Instead of a path to a node, there are two keywords that can be used instead:
##[br][br]
## [code]"self"[/code] points to a variable in the [TargetInitializer] itself ([code]"self:some_value[/code]).
##[br]
## [code]"%category_name"[/code] points to a [ConfProperty]. Replace "category_name" with the name of the category
## the [ConfProperty] is in, with the path as the subnames of the [NodePath] ([code]"%test:path:used:for:property"[/code]).
##[br][br]
## [b]Protip:[/b] Use [code]"/"[/code] in [param editor_name] to divide properties into subgroups. 
func add_configurable_property(category_name: String, editor_name: String, path_indexed: NodePath, default_value: Variant, default_is_enum: bool = false) -> Error:
	if not has_category(category_name):
		printerr("TargetInitializer: category %s not initialized." % [category_name])
		return ERR_CANT_CREATE
	
	var object: Object = null
	
	if not Engine.is_editor_hint():
		if not target:
			await target_set
		
		object = _get_object(path_indexed)
		
		if not object:
			printerr("TargetInitializer: target object %s not found or does not exist." % [path_indexed.get_concatenated_names()])
			return ERR_CANT_CREATE
	
	var new_conf_property: ConfProperty = ConfProperty.new(
		object,
		JILibrary.get_nodepath_subnames(path_indexed),
		default_value,
		default_is_enum
	)
	
	_configurable_properties[category_name].append({
		editor_name = editor_name,
		path = path_indexed,
		conf_property = new_conf_property
	})
	notify_property_list_changed()
	return OK



## Returns the value of a [ConfProperty]. [param search_string] can either be the editor name
## or the path of the property.
##[br][br] 
## Returns [code]null[/code] if the [ConfProperty] does not exist.
func get_conf_prop_value(category_name: String, search_string: String) -> Variant:
	var conf_property: ConfProperty = _get_conf_property(category_name, search_string)
	
	if conf_property:
		return conf_property.get_value()
	
	return null


## Returns the default value of a [ConfProperty].[param search_string] can either be the editor name
## or the path of the property.
##[br][br]
## Returns [code]null[/code] if the [ConfProperty] does not exist.
func get_conf_prop_default_value(category_name: String, search_string: String) -> Variant:
	var conf_property: ConfProperty = _get_conf_property(category_name, search_string)
	
	if conf_property:
		return conf_property.get_value_default()
	
	return null


## Returns a [ConfProperty] as a [PropertyRef]. See [method ConfProperty.get_property_ref] for more.
## [param search_string] can either be the editor name or the path of the property.
##[br][br]
## Returns [code]null[/code] if the [ConfProperty] does not exist.
func get_conf_prop_as_prop_ref(category_name: String, search_string: String, auto_update: bool = false) -> PropertyRef:
	var conf_property: ConfProperty = _get_conf_property(category_name, search_string)
	
	if conf_property:
		return conf_property.get_property_ref(auto_update)
	
	return null


## Returns true if the property exists under [param category_name]. [param search_string] can either be the editor name
## or the path of the property.
##[br][br]
## Returns false if [method has_category] returns false or if the property does not exist in that category.
func category_has_property(category_name: String, search_string: String) -> bool:
	if not has_category(category_name):
		return false
	
	for i in _configurable_properties[category_name]:
		if search_string.matchn(i.editor_name):
			return true
	
	for i in _configurable_properties[category_name]:
		if search_string.matchn(String(i.path)):
			return true
	
	return false


## Returns true if category with name [param category_name] exists (added with [method add_category]).
func has_category(category_name: String) -> bool:
	return _configurable_properties.has(category_name)
