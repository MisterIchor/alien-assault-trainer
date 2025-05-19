extends Node

var health_max: int = 100:
	set = set_health_max
var health_current: int = 100:
	set = set_health_current
var defense_base: int = 0
var regen_rate: float = 0.0
var regen_cap_mod: float = 1.0

var bleedout_perc_of_critical: float = 0.75:
	set(value):
		bleedout_perc_of_critical = value
		_update_values()
var critical_perc_of_max: float = 0.2:
	set(value):
		critical_perc_of_max = value
		_update_values()

var _health_critical: int = 20
var _health_bleedout: int = -15
var _defense_current: int = 0

@onready var regen_timer: Timer = $RegenTimer



func _ready() -> void:
	regen_timer.timeout.connect(_on_RegenTimer_timeout)


func _update_values() -> void:
	_health_critical = health_max * critical_perc_of_max
	_health_bleedout = _health_critical * bleedout_perc_of_critical



func set_health_max(value: int) -> void:
	var set_current_to_max: bool = (health_current == health_max)
	health_max = value
	_update_values()
	
	if set_current_to_max:
		health_current = health_max


func set_health_current(value: int) -> void:
	health_current = min(value, health_max)



func get_health_critical() -> int:
	return _health_critical


func get_health_bleedout() -> int:
	return _health_bleedout



func _on_RegenTimer_timeout() -> void:
	health_current += regen_rate
