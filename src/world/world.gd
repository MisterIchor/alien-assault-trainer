extends Node2D

signal unit_added(unit, unit_position, is_player_controlled)
signal item_added(item, item_position)

const TILE_SIZE: Vector2 = Vector2(16, 16)
const UNIT: PackedScene = preload("res://src/entities/unit/base/unit.tscn")
const ITEM: PackedScene = preload("res://src/entities/item/base/item.tscn")

var is_lighting_enabled: bool = true:
	set = set_is_lighting_enabled
var is_fog_of_war_enabled: bool = true:
	set = set_is_fog_of_war_enabled

var _fog_of_war_map: TileMapLayer = null

@onready var units: Node2D = $MapLayer/Units
@onready var items: Node2D = $MapLayer/Items
@onready var fog_of_war_layer: CanvasLayer = $FogOfWarLayer
@onready var mood_lighting: CanvasModulate = $MapLayer/MoodLighting
@onready var map: TileMapLayer = $MapLayer/Map
@onready var lights: Node2D = $MapLayer/Lights



func _ready() -> void:
	_fog_of_war_map = map.duplicate()
	_fog_of_war_map.material = ShaderMaterial.new()
	_fog_of_war_map.material.shader = preload("res://src/world/fog_of_war.gdshader")
	fog_of_war_layer.add_child(_fog_of_war_map)
	add_unit(preload("res://src/entities/unit/base/template/unit_template_default.tres"), Vector2(256, 256), true)
	#add_item(preload("res://src/entities/item/base/template/item_default.tres"), Vector2(256, 256))


func add_unit(template: EntityTemplate, pos: Vector2, is_player_controlled: bool) -> void:
	var new_unit: Unit = UNIT.instantiate()
	new_unit.position = pos
	units.add_child(new_unit)
	new_unit.template = template
	new_unit.inventory.item_dropped.connect(_on_item_dropped)
	await get_tree().process_frame
	unit_added.emit(new_unit, pos, is_player_controlled)


func add_item(template: ItemTemplate, pos: Vector2) -> void:
	var new_item: Item = ITEM.instantiate()
	new_item.position = pos
	items.add_child(new_item)
	new_item.template = template



func set_is_lighting_enabled(value: bool) -> void:
	is_lighting_enabled = value
	lights.visible = is_lighting_enabled
	mood_lighting.visible = is_lighting_enabled


func set_is_fog_of_war_enabled(value: bool) -> void:
	is_fog_of_war_enabled = value
	fog_of_war_layer.visible = value



func _on_item_dropped(item: Item, idx: int) -> void:
	item.reparent(items)
