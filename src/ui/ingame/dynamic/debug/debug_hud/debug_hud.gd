extends Control

var unit: Unit = null:
	set = set_unit

@onready var health_label: Label = $HBoxContainer/HealthLabel
@onready var stamina_label: Label = $HBoxContainer/StaminaLabel
@onready var speed_label: Label = $HBoxContainer/SpeedLabel
@onready var look_angle_label: Label = $HBoxContainer/LookAngleLabel
@onready var equipped_item_label: Label = $HBoxContainer/EquippedItemLabel
@onready var current_state_label: Label = $HBoxContainer/CurrentStateLabel



func _ready() -> void:
	set_process(false)


func _process(delta: float) -> void:
	health_label.text = str("Health: ", unit.health.health_current, "/", 
			unit.health.health_max, " (", unit.health._health_critical, ") ", 
			" (", unit.health._health_bleedout, ")")
	stamina_label.text = str("Stamina: ", roundf(unit.stamina.stamina_current), "/", unit.stamina.stamina_max, " (", unit.stamina.regen_rate, ")")
	speed_label.text = str("Speed: ", unit.movement.speed_current.round(), " (", unit.movement.speed_default, ")")
	look_angle_label.text = str("Look Angle: ", snapped(unit.movement.look_angle, 0.0001))
	equipped_item_label.text = str("Equipped Item: ", unit.inventory.get_equipped_item().name, " (",unit.inventory.equipped_item, ")")
	current_state_label.text = str("Current State: ", unit.state_machine.current_state.name)


func set_unit(new_unit: Unit) -> void:
	unit = new_unit
	set_process(not unit == null)
