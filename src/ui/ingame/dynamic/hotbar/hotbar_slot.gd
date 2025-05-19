extends Control

var slot_number: int = 1:
	set = set_slot_number
var is_equipped: bool = false:
	set = set_is_equipped
var icon: Texture = null:
	set = set_icon

@onready var slot_number_label: Label = $MarginContainer/SlotNumberLabel
@onready var item_icon: TextureRect = $MarginContainer/ItemIcon
@onready var equipped_label: Label = $MarginContainer/EquippedLabel



func set_slot_number(value: int) -> void:
	if not slot_number_label:
		await ready
	
	slot_number = value
	slot_number_label.text = str(slot_number, ".")


func set_is_equipped(value: bool) -> void:
	if not equipped_label:
		await ready
	
	is_equipped = value
	equipped_label.visible = is_equipped


func set_icon(new_icon: Texture) -> void:
	if not item_icon:
		await ready
	
	icon = new_icon
	item_icon.texture = icon
