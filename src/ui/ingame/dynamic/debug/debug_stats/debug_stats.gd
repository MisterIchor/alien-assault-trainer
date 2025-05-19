extends Control

var unit: Unit = null:
	set = set_unit

@onready var health_label: Label = $VBoxContainer/HealthLabel
@onready var stamina_label: Label = $VBoxContainer/StaminaLabel
@onready var speed_label: Label = $VBoxContainer/SpeedLabel
@onready var look_angle_label: Label = $VBoxContainer/LookAngleLabel
@onready var equipped_item_label: Label = $VBoxContainer/EquippedItemLabel
@onready var inventory_label: Label = $VBoxContainer/InventoryLabel
@onready var current_state_label: Label = $VBoxContainer/CurrentStateLabel



func _ready() -> void:
	set_process(false)


func _process(delta: float) -> void:
	health_label.text = str("Health: ", unit.health.health_current, "/", 
			unit.health.health_max, " (", unit.health._health_critical, ") ", 
			" (", unit.health._health_bleedout, ")")
	stamina_label.text = str("Stamina: ", roundf(unit.stamina.stamina_current), "/", unit.stamina.stamina_max, " (", unit.stamina.rate, ")")
	speed_label.text = str("Speed: ", unit.movement.speed_current.round(), " (", unit.movement.speed_default, ")")
	look_angle_label.text = str("Look Angle: ", snapped(unit.movement.look_angle, 0.0001))
	equipped_item_label.text = str("Equipped Item: ", unit.inventory.get_equipped_item().name, " (",unit.inventory.equipped_item, ")")
	inventory_label.text = str("Inventory: ", unit.inventory.hotbar)
	current_state_label.text = str("Current State: ", unit.unit_state_machine.state.name)



func set_unit(new_unit: Unit) -> void:
	unit = new_unit
	set_process(not unit == null)
