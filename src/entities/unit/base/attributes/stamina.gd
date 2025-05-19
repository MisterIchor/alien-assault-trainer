extends Node

var stamina_current: float = 100.0
var stamina_max: int = 100
var regen_rate: float = 0.0
var regen_cap_mod: float = 1.0

@onready var regen_timer: Timer = $RegenTimer



func _ready() -> void:
	regen_timer.timeout.connect(_on_RegenTimer_timeout)


func fatigue(by: float) -> void:
	stamina_current -= by
	stamina_current = clamp(stamina_current, 0, stamina_max)



func _on_RegenTimer_timeout() -> void:
	stamina_current += regen_rate
	stamina_current = clamp(stamina_current, 0, stamina_max)
