extends Node

var ranged_accuracy_modifier: float = 1.0
var melee_damage_modifier: float = 1.0
var last_hit_from: Unit = null:
	set(value):
		last_hit_from = value
		
		if last_hit_from:
			_last_hit_from_angle = get_parent().global_position.angle_to_point(last_hit_from.global_position)
var last_attack_hit: Unit = null:
	set(value):
		last_attack_hit = value
		
		if last_attack_hit:
			_last_attack_hit_angle = get_parent().global_position.angle_to_point(last_attack_hit.global_position)

var _last_hit_from_angle: float = 0.0
var _last_attack_hit_angle: float = 0.0



func get_last_hit_from_angle() -> float:
	return _last_hit_from_angle


func get_last_attack_hit_angle() -> float:
	return _last_attack_hit_angle
