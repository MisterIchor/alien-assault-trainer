class_name Item
extends RigidBody2D

signal item_pickup(item: Item)
signal item_used(item: Item, item_type: String, interaction_type: String)
signal item_equipped(item: Item)
signal item_dropped(item: Item)
signal item_hit(item: Item, by: Unit)

var template: ItemTemplate = null:
	set = set_template
var owned_by: Unit = null:
	set = set_owned_by
var is_equipped: bool = false:
	set = set_is_equipped
var is_highlighted: bool = false:
	set = set_is_highlighted

var _highlight_shader: Shader = preload("res://src/entities/item/base/item_highlight.gdshader")

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var collision_polygon_2d: CollisionPolygon2D = $CollisionPolygon2D
@onready var audio_emitter: AudioEmitter = $AudioEmitter
@onready var item_state_machine: Node = $ItemStateMachine



func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_entered.connect(item_state_machine._on_body_entered)
	item_dropped.connect(item_state_machine._on_item_dropped)
	item_hit.connect(item_state_machine._on_item_hit)
	item_used.connect(item_state_machine._on_item_used)
	sprite_2d.material = ShaderMaterial.new()



func use(interaction_type: String) -> void:
	item_used.emit(self, template.type, interaction_type)


func hit(from: Unit) -> void:
	item_hit.emit(self, from)



func set_template(new_template: ItemTemplate) -> void:
	template = new_template
	
	if not is_inside_tree():
		await ready
	
	#var item_setup: ItemSetup = template.setup_script.new()
	#
	#item_setup.item = self
	#item_setup.configurable_values = template.configurable_values
	#item_setup._setup()
	#item_state_machine._initialize_states(item_setup.states)
	#collision_polygon_2d.polygon = template.collision_poly
	#sprite_2d.texture = template.sprite_world
	#name = template.resource_name if not template.resource_name.is_empty() else "Item"


func set_owned_by(unit: Unit) -> void:
	owned_by = unit



func set_is_equipped(value: bool) -> void:
	is_equipped = value
	
	if not sprite_2d:
		await ready
	
	if is_equipped:
		sprite_2d.texture = template.sprite_equipped
		freeze = true
		item_equipped.emit(self)
	else:
		sprite_2d.texture = template.sprite_world
		freeze = false


func set_is_highlighted(value: bool) -> void:
	is_highlighted = value
	
	if is_highlighted:
		sprite_2d.material.shader = _highlight_shader
	else:
		sprite_2d.material.shader = null



func _on_body_entered(body: Node) -> void:
	item_hit.emit(self, body)
