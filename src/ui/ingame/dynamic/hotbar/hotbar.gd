extends Control

const ANIMATION_SPEED: float = 0.1
const HOTBAR_ITEM_DISTANCE: float = 40
const ROTATION_CLAMP: float = 180

var unit: Unit = null:
	set = set_unit

var _is_expanded: bool = false:
	set = _set_is_expanded
var _is_slots_in_reverse: bool = false:
	set = _set_is_slots_in_reverse
var _items: Array[Item] = []
var _item_distance: float = 0.0

@onready var timer: Timer = $Timer
@onready var hotbar_slots: Control = $HotbarSlots
@onready var equipped_label: Label = $EquippedLabel



func _ready() -> void:
	for i in hotbar_slots.get_child_count():
		hotbar_slots.get_child(i).slot_number = i + 1
		_items.append(null)
	
	timer.timeout.connect(_on_Timer_timeout)
	set_process(false)


func _process(delta: float) -> void:
	var rotation_increment: float = deg_to_rad(ROTATION_CLAMP / (hotbar_slots.get_child_count() - 1))
	var current_increment: float = deg_to_rad(ROTATION_CLAMP / 2)
	
	for i in hotbar_slots.get_children():
		i.position = Vector2(_item_distance, 0).rotated(unit.movement.look_angle + current_increment)
		current_increment += rotation_increment
	
	_is_slots_in_reverse = unit.movement.look_angle < PI * 0.25 and unit.movement.look_angle > -PI * 0.75


func _update_slots() -> void:
	var items_ordered: Array = _get_items_ordered()
	
	for i: int in items_ordered.size():
		var slot: Control = hotbar_slots.get_child(i)
		slot.set_icon(null if not items_ordered[i] else items_ordered[i].template.sprite_world)


func _get_hotbar_slots_ordered() -> Array:
	var order: Array = hotbar_slots.get_children()
	
	if _is_slots_in_reverse:
		order.reverse()
	
	return order


func _get_items_ordered() -> Array:
	var order: Array = _items.duplicate()
	
	if _is_slots_in_reverse:
		order.reverse()
	
	return order



func show_hotbar() -> void:
	if not timer.is_stopped():
		timer.stop()
	
	timer.start()
	_is_expanded = true



func set_unit(new_unit: Unit) -> void:
	unit = new_unit
	set_process(not unit == null)
	
	if not unit:
		return
	
	unit.inventory.item_added.connect(_on_item_added)
	unit.inventory.item_dropped.connect(_on_item_dropped)
	unit.inventory.item_equipped.connect(_on_item_equipped)




func _set_is_expanded(value: bool) -> void:
	if _is_expanded == value:
		return
	
	_is_expanded = value
	var tween: Tween = create_tween()
	
	if _is_expanded:
		tween.parallel().tween_property(self, "_item_distance", HOTBAR_ITEM_DISTANCE, ANIMATION_SPEED)
		tween.parallel().tween_property(self, "modulate", Color(modulate, 1.0), ANIMATION_SPEED)
	else:
		tween.parallel().tween_property(self, "_item_distance", 0, ANIMATION_SPEED)
		tween.parallel().tween_property(self, "modulate", Color(modulate, 0.0), ANIMATION_SPEED)


func _set_is_slots_in_reverse(value: bool) -> void:
	if _is_slots_in_reverse == value:
		return
	
	_is_slots_in_reverse = value
	
	var slots: Array = hotbar_slots.get_children()
	slots.reverse()
	
	for i in slots.size():
		hotbar_slots.move_child(slots[i], i)



func _on_item_added(item : Item, idx: int) -> void:
	if idx > _items.size():
		return
	
	_items[idx] = item
	_update_slots()
	show_hotbar()


func _on_item_dropped(item: Item, idx: int) -> void:
	_items[idx] = null
	_update_slots()
	show_hotbar()


func _on_item_equipped(item: Item, idx: int) -> void:
	var ordered_slots: Array = _get_hotbar_slots_ordered()
	
	for i in ordered_slots:
		i.is_equipped = i == ordered_slots[idx]
	
	show_hotbar()
	equipped_label.text = item.name


func _on_Timer_timeout() -> void:
	_is_expanded = false
