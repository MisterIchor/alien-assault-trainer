extends Node

var players: int = 1
var is_online: bool = false
var local_unit: Unit = null:
	set = set_local_unit
var time_elasped: int = 0
var local_stats: Dictionary = {
	name = "",
	kills = 0,
	shots_fired = 0,
	shots_landed = 0,
	melee_attacks_landed = 0,
	damage_taken = 0,
	is_dead = false,
	misc = {}
}

@onready var timer: Timer = $Timer
@onready var world: Node2D = $World
@onready var unit_interface: Camera2D = $UnitInterface



func _ready() -> void:
	timer.timeout.connect(_on_Timer_timeout)
	world.unit_added.connect(_on_World_unit_added)



func add_game_script(script: GDScript) -> void:
	return



func set_local_unit(new_unit: Unit) -> void:
	local_unit = new_unit
	unit_interface.target_unit = local_unit
	local_unit.is_local = true



func _on_Timer_timeout() -> void:
	time_elasped += 1


func _on_World_unit_added(unit: Unit, _pos: Vector2, is_player_controlled: bool) -> void:
	if is_player_controlled:
		if not local_unit:
			local_unit = unit
