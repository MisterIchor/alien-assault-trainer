extends Node

signal reload_started
signal reload_finished
signal reloaded_one
signal rechambered
signal shoot_success
signal shoot_out_of_ammo
signal shoot_needs_rechamber
signal attack_delay_passed

const PROJECTILE: PackedScene = preload("res://src/projectile/Projectile.tscn")

var unit: Unit = null
var length: float = 0
var ammo_used: ItemTemplate = load("res://src/entities/item/created_items/misc/ammo/ammo_template_default.tres")
var capacity: int = 30
var attack_delay: float = -1
var rechamber_speed: float = 1
var reload_speed: float = 2
var needs_rechamber: bool = false

var _ammo_loaded: int = 30
var _attack_timer: Timer = Timer.new()
var _reload_timer: Timer = Timer.new()



func _ready() -> void:
	_attack_timer.process_callback = Timer.TIMER_PROCESS_PHYSICS
	_attack_timer.one_shot = true
	_reload_timer.process_callback = Timer.TIMER_PROCESS_PHYSICS
	_reload_timer.timeout.connect(_on_ReloadTimer_timeout)
	_attack_timer.timeout.connect(attack_delay_passed.emit)
	add_child(_reload_timer)
	add_child(_attack_timer)


func _rand_dir(direction: float) -> float:
	if not unit:
		return direction
	
	var variance: float = clamp(1 - unit.combat.ranged_accuracy, 0, 1)
	return direction - randf_range(-variance, variance)



func shoot(position: Vector2, direction: float) -> void:
	if _ammo_loaded <= 0:
		shoot_out_of_ammo.emit()
		return
	
	if not _attack_timer.is_stopped():
		return
	
	if needs_rechamber:
		shoot_needs_rechamber.emit()
		return
	
	var new_projectile: Projectile = PROJECTILE.instantiate()
	
	new_projectile.force = 20
	new_projectile.height = 800
	new_projectile.direction = Vector2.from_angle(_rand_dir(direction))
	new_projectile.global_position = position
	add_child(new_projectile)
	new_projectile.set_active(true)
	_ammo_loaded -= 1
	
	if _ammo_loaded <= 0:
		needs_rechamber = true
	
	if not attack_delay == -1:
		_attack_timer.start(attack_delay)
	
	shoot_success.emit()


func reload() -> void:
	if not _reload_timer.is_stopped():
		return
	
	#_reload_timer.one_shot = reload_one_at_a_time
	_reload_timer.start(reload_speed)
	reload_started.emit()


func rechamber() -> void:
	await get_tree().create_timer(rechamber_speed).timeout
	print('rechamber')
	needs_rechamber = false
	rechambered.emit()



func _on_ReloadTimer_timeout() -> void:
	#if not reload_one_at_a_time:
	var ammo_taken: int = max(capacity, unit.inventory.ammo.get(ammo_used))
	
	_ammo_loaded = ammo_taken
	unit.inventory.ammo[ammo_used] -= ammo_taken
	reload_finished.emit()
	print("reloaded")
	_reload_timer.stop()
	
	if needs_rechamber:
		await rechamber()
	#else:
		#if unit.inventory.ammo[ammo_used] == 0 or _ammo_loaded == capacity:
			#_reload_timer.stop()
			#
			#if _needs_rechamber:
				#await rechamber()
			#
			#reload_finished.emit()
			#return
		
		unit.inventory.ammo[ammo_used] -= 1
		_ammo_loaded += 1
		reloaded_one.emit()


func _on_item_equipped(item: Item) -> void:
	unit = item.owned_by


func _on_item_dropped(_item: Item) -> void:
	unit = null
