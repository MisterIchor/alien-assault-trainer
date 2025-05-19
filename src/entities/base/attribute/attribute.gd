class_name Attribute
extends Node

## Emitted when [method get_property_from_attribute] is called.
signal property_requested(requester: Attribute, attribute_name: String, property_name: String)

var _requested_properties: Dictionary[String, PropertyRef] = {}
var _requested_property: PropertyRef = null



func _get_formatted_string(attribute_name: String, property_name: String) -> String:
	return str(attribute_name, ":", property_name)


## Returns a [PropertyRef] with the property [param property_name] from attribute [param attribute_name]. 
##[br][br]
## It will wait until the node is ready before getting the property. If the property was not referenced before,
## it will request the property from the [Entity] (via [signal property_requested]). If the [Attribute] has 
## the property, it will be sent back to the requester as a [PropertyRef] and cached.
##[br][br]
## Returns [code]null[/code] if the requested property or [Attribute] could not be found.
func get_property_from_attribute(attribute_name: String, property_name: String) -> PropertyRef:
	if not is_node_ready():
		await ready
	
	var formatted_string: String = _get_formatted_string(attribute_name, property_name)
	
	if _requested_properties.get(formatted_string):
		return _requested_properties[formatted_string]
	
	property_requested.emit(attribute_name, property_name)
	
	if _requested_property:
		_requested_properties[_get_formatted_string(formatted_string, property_name)] = _requested_property
		return _requested_property
	
	return null


## Returns the property [param property_name] as a [PropertyRef].
##[br][br]
## Return [code]null[/code] if the property was not found.
func get_property_ref(property_name: String) -> PropertyRef:
	if not get(property_name):
		return null
	
	return PropertyRefTracker.get_property_ref(self, property_name)



func _on_requested_property_sent(requester: Attribute, property_ref: PropertyRef) -> void:
	if not requester == self:
		return
	
	_requested_property = weakref(property_ref)
