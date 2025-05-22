class_name Entity
extends Node2D

## Base class used for all in-game physical objects within the Silent Framework.

## [Entity] 

## Emitted when [member body] collides with another [CollisionObject2D].
signal body_entered(body: Node)
## Emitted when an [Attribute] requests a property. [param property_ref] can be [code]null[/code] if
## the requested property could not be found.
signal requested_property_sent(requester: Attribute, property_ref: PropertyRef)
## A [CollisionObject2D] to associate with this [Entity]. All bodies except [StaticBody2D] will allow [EntityState]s
## within [EntityStateMachine.states] to handle collision behavior within [method EntityState._handle_collision].
@export var body: CollisionObject2D = null:
	set = set_body
## Template used for this [Entity]. Setting this value with a new [EntityInitializer] requires that this
## tags within [member _template_primary_tag_requirements] are found when [EntityInitializer.get_tags_primary]
## is called. Otherwise, [member template] will remain the same.
var template: EntityInitializer = null:
	set = set_template
@onready var state_machine: EntityStateMachine = $EntityStateMachine
@onready var audio_emitter: AudioEmitter = $AudioEmitter

## A [PackedStringArray] containing tags that are required when setting [member template].
## If the new [EntityInitializer] does not have all of the primary tags within this array, [member template]
## will not be set and remain as the previous value.
var _template_primary_tag_requirements: PackedStringArray = []
## A set of tags that will be return in addition to [method EntityInitializer.get_tags_primary] when
## [method get_tags_primary] is called.
var _additional_primary_tags: PackedStringArray = []
## The default name for this entity. Replace this when extending this class.
var _default_name: String = "Entity"



func _init() -> void:
	name = _default_name


func _ready() -> void:
	body_entered.connect(state_machine._on_collision)


func _process(delta: float) -> void:
	if body is CharacterBody2D:
		var collision: KinematicCollision2D = body.get_last_slide_collision()
		
		if collision:
			if collision.get_collider() is Entity:
				body_entered.emit(collision.get_collider())



## Setter for [member body].
func set_body(new_body: PhysicsBody2D) -> void:
	if body is RigidBody2D or body is Area2D:
		body.body_entered.disconnect(_on_body_entered)
	
	body = new_body
	
	if body is RigidBody2D or body is Area2D:
		body.body_entered.connect(_on_body_entered)


## Setter for [member template].
func set_template(new_template: EntityInitializer) -> void:
	if new_template:
		for i in _template_primary_tag_requirements:
			if not i in new_template.get_tags_primary():
				return
	
	template = new_template
	
	if not template:
		return
	
	if not is_inside_tree():
		await ready
	
	var entity_setup: EntitySetup = template.setup_script.new()
	
	entity_setup.entity = self
	entity_setup._overwrite_configurable_values(template.configurable_values)
	entity_setup._setup()
	state_machine.initialize_states(entity_setup.get_states())
	name = template.resource_name if not template.resource_name.is_empty() else _default_name


## Returns the primary tags this [Entity] possess. This includes the tags found in
## [member _additional_primary_tags] and, if [member template] is set, the tags acquired
## from [method EntityInitializer.get_tags_primary]. 
func get_tags_primary() -> PackedStringArray:
	var tags: PackedStringArray = _additional_primary_tags.duplicate()
	
	if template:
		tags.append_array(template.get_tags_primary())
	
	return tags


## Returns the tags found within [method EntityInitializer.get_tags_secondary]. If
## [member template] is [param null], return an empty array.
func get_tags_secondary() -> PackedStringArray:
	return template.get_tags_secondary() if template else []



func _on_body_entered(body: Node) -> void:
	body_entered.emit(body)


func _on_Attribute_property_requested(requester: Attribute, attribute_name: String, property_name: String) -> void:
	var attribute: Attribute = get_node_or_null(attribute_name)
	
	if not attribute:
		requested_property_sent.emit(requester, null)
		return
	
	requested_property_sent.emit(requester, attribute.get_property_ref(property_name))
