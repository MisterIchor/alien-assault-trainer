extends EntitySetup

#func _init() -> void:
	#configurable_values.damage = 0
	#configurable_values.force = 400
#
#
#
#func _setup() -> void:
	#var attribute: Node = preload("res://src/entities/item/created_items/misc/ammo/attributes/ammo.gd").new()
	#
	#item.add_child(attribute)
	#attribute.name = "Ammo"
	#attribute.force = configurable_values.force
	#attribute.damage = configurable_values.damage
