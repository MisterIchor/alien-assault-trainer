extends Node

signal item_added(item, idx)
signal item_dropped(item, idx)
signal item_equipped(item, idx)
signal inventory_updated(inventory)

var default_item: Item = preload("res://src/entities/item/base/item.tscn").instantiate()
var equipped_item: int = 0
var hotbar: Array = [null, null, null, null, null]
var ammo: Dictionary = {}
var weight: int = 0



func _ready() -> void:
	var template: ItemTemplate = load("res://src/entities/item/created_items/misc/ammo/ammo_template_default.tres")
	ammo[template] = 30
	add_child(default_item)



func add_item(item: Item) -> void:
	if item.template.type.matchn("ammo"):
		return
	
	var empty_slot: int = get_empty_slot()
	
	if empty_slot == -1:
		drop_equipped_item()
		empty_slot = equipped_item
	
	hotbar[empty_slot] = item
	item.owned_by = get_parent()
	item.position = Vector2()
	
	if equipped_item == empty_slot:
		equip_item(equipped_item)
	
	_update_inventory()
	item_added.emit(item, empty_slot)


func drop_equipped_item() -> void:
	if not hotbar[equipped_item]:
		return
	
	var dropped_item: Item = hotbar[equipped_item]
	dropped_item.owned_by = null
	hotbar[equipped_item] = null
	item_dropped.emit(dropped_item, equipped_item)
	_update_inventory()


func equip_item(idx: int) -> void:
	equipped_item = idx
	
	if not hotbar[equipped_item]:
		item_equipped.emit(default_item, equipped_item)
	else:
		item_equipped.emit(hotbar[equipped_item], equipped_item)
	
	_update_inventory()


func drop_item_in_slot(idx: int) -> void:
	var item: Item = hotbar[idx]
	
	if not item:
		return
	
	item_dropped.emit(item, idx)
	_update_inventory()


func empty_inventory() -> void:
	for i in hotbar.size():
		drop_item_in_slot(i)



func get_empty_slot() -> int:
	if get_equipped_item() == default_item:
		return equipped_item
	
	for i in hotbar.size():
		if not hotbar[i]:
			return i
	
	return -1


func get_equipped_item() -> Item:
	return default_item if not hotbar[equipped_item] else hotbar[equipped_item]


func is_default_equipped() -> bool:
	return not hotbar[equipped_item]



func _update_inventory() -> void:
	weight = 0
	
	for i in hotbar.size():
		if not hotbar[i]:
			continue
		
		hotbar[i].visible = (i == equipped_item)
		weight += hotbar[i].template.weight
	
	if default_item:
		default_item.visible = is_default_equipped()
		
	inventory_updated.emit(hotbar, ammo)
