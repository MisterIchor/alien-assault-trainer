class_name Unit
extends Entity

signal unit_hit(unit: Unit, damage: int, from: Unit)
signal unit_healed(unit: Unit, by, from)
signal unit_dead(unit: Unit)

var is_local: bool = false:
	set = set_is_local

@onready var health: Node = $Health
@onready var inventory: Node = $Inventory
@onready var movement: Node = $Movement
@onready var stamina: Node = $Stamina
@onready var combat: Node = $Combat
@onready var visual_body: Node2D = $UnitBody/VisualBody
@onready var poi_detection: Node2D = $UnitBody/POIDetection
@onready var item_detection: Area2D = $UnitBody/ItemDetection
@onready var light_of_war: PointLight2D = $UnitBody/LightOfWar



func _ready() -> void:
	unit_dead.connect(_on_Unit_dead)
	#health.incapacitated.connect(_on_Health_incapacitated)
	#health.health_depleted.connect(_on_Health_depleted)
	inventory.item_added.connect(visual_body._on_item_added)
	inventory.item_added.connect(_on_Inventory_item_added)
	inventory.item_dropped.connect(_on_Inventory_item_dropped)
	#pickup(load("res://src/ent/item/base/item.tscn").instantiate())


func _physics_process(delta: float) -> void:
	body.velocity = movement.speed_current
	visual_body.look_angle = movement.look_angle


func use_equipped_item(interaction_type: String) -> void:
	inventory.get_equipped_item().use(interaction_type)


func switch_item(idx: int) -> void:
	inventory.equip_item(idx)


func pickup() -> void:
	var closest_item: Item = item_detection.get_closest()
	
	if closest_item:
		inventory.add_item(item_detection.get_closest())


func hit(damage: int, from: Unit) -> void:
	health.set_health_current(health.health_current - damage)
	stamina.fatigue(float(damage) / 2)
	combat.last_hit_from = from
	unit_hit.emit(self, damage, from)


func heal(by: int, from: Unit) -> void:
	health.set_current_health(health.health_current + by)
	unit_healed.emit(self, by, from)



func set_is_local(value: bool) -> void:
	is_local = value
	
	if not is_inside_tree():
		await ready
	
	light_of_war.enabled = value
	state_machine.active = value



func get_closest_poi() -> Node2D:
	return poi_detection.get_closest_poi()



func _on_Inventory_item_added(item: Item, _idx: int) -> void:
	item_detection.add_exception(item)


func _on_Inventory_item_dropped(item: Item, _idx: int) -> void:
	item_detection.remove_exception(item)


func _on_Unit_dead(_unit: Unit) -> void:
	state_machine.state = state_machine.get_node("Dead")


func _on_Health_depleted() -> void:
	unit_dead.emit(self)


func _on_Health_incapacitated() -> void:
	return
