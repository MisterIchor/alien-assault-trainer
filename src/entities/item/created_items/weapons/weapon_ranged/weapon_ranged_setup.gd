extends EntitySetup

func _init() -> void:
	add_configurable_value("attributes", "length", 20.0)
	add_configurable_value("attributes", "capacity", 30)
	add_configurable_value("attributes", "attack_delay", -1.0)
	add_configurable_value("attributes", "ammo_used", EntityTemplate.new())
	add_configurable_value("reload", "reload_speed", 2.0)
	add_configurable_value("reload", "rechamber_speed", 1.0)
	add_configurable_value("reload", "reload_one_at_a_time", false)
	add_configurable_value("reload", "rechamber_after_each_shot", false)
	add_state(load("res://src/entities/item/created_items/weapons/weapon_ranged/states/weapon_ranged_primary.gd"))
	add_tag("weapon")
	add_tag("ranged")


#func _setup() -> void:
	#var weapon_ranged: Node = load("res://src/entities/item/created_items/weapons/weapon_ranged/attributes/weapon_ranged.gd").new()
	#
	#entity.add_child(weapon_ranged)
	#weapon_ranged.name = "WeaponRanged"
	#weapon_ranged.length = get_configurable_value("attributes", "length")
	#weapon_ranged.ammo_used = get_configurable_value("attributes", "ammo_used")
	#weapon_ranged.capacity = get_configurable_value("attributes", "capacity")
	#weapon_ranged.attack_delay = get_configurable_value("attributes", "ammo_used")
	#weapon_ranged.rechamber_after_each_shot = get_configurable_value("reload", "rechamber_after_each_shot")
	#weapon_ranged.reload_speed = get_configurable_value("reload", "reload_speed")
	#weapon_ranged.reload_one_at_a_time = get_configurable_value("reload", "reload_one_at_a_time")
	
	#if entity.owned_by:
		#weapon_ranged.inventory = entity.owned_by.inventory
	#
	#entity.audio_emitter.add_signal(weapon_ranged.get_path(), "reload_started", "reload_started")
	#entity.audio_emitter.add_signal(weapon_ranged.get_path(), "reload_finished", "reload_finished")
	#entity.audio_emitter.add_signal(weapon_ranged.get_path(), "reloaded_one", "reloaded_one")
	#entity.audio_emitter.add_signal(weapon_ranged.get_path(), "rechambered", "rechambered")
	#entity.audio_emitter.add_signal(weapon_ranged.get_path(), "shoot_success", "shoot_success")
	#entity.audio_emitter.add_signal(weapon_ranged.get_path(), "shoot_failed", "shoot_failed")
