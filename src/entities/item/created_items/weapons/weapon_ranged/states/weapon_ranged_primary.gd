extends ItemState

@onready var weapon_ranged: Node = item.get_node("WeaponRanged")



func _enter() -> void:
	weapon_ranged.shoot(item.global_position, item.global_rotation)
	await weapon_ranged.attack_delay_passed
	finished.emit()
