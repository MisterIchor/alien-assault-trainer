class_name UnitTemplate
extends Resource

@export var setup_script: GDScript = null
@export_group("Stats")
@export var health_max: int = 100
@export var stamina_max: int = 100
@export var speed_max: int = 400
@export var defense_base: int = 0
@export_group("Inventory")
@export var default_item: ItemTemplate = null
@export var starting_hotbar: Array[ItemTemplate] = [null, null, null, null, null]
@export var can_manipulate_hotbar: bool = false
