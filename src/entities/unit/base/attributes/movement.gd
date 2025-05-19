extends Node

const INFLUENCE_BASE: float = 0.055
const AGILITY_MOD: float = 0.1
const OPPOSING_MOTION_MOD: float = 0.02
const EXCESSIVE_SPEED_MULTIPLIER: float = 0.8

var speed_default: int = 300
var speed_current: Vector2 = Vector2()
var motion_dir: Vector2 = Vector2()
var agility: float = 1.0
var look_angle: float = 0

var _movement_inputs: Vector2 = Vector2()



func _unhandled_key_input(event: InputEvent) -> void:
	_movement_inputs = Vector2()
	
	if Input.is_action_pressed("move_up"):
		_movement_inputs.y = -1
	
	if Input.is_action_pressed("move_down"):
		_movement_inputs.y = 1
	
	if Input.is_action_pressed("move_left"):
		_movement_inputs.x = -1
	
	if Input.is_action_pressed("move_right"):
		_movement_inputs.x = 1
	



func look(target_dir: Vector2) -> void:
	look_angle = target_dir.angle()


func cancel_motion() -> void:
	speed_current = Vector2()
	motion_dir = Vector2()


func cancel_movement_inputs() -> void:
	_movement_inputs = Vector2()


func move(target_dir: Vector2, percentage_of_default: float = 1.0) -> void:
	var speed_normalized: Vector2 = target_dir.normalized() * (speed_default * percentage_of_default)
	
	for axis in 2:
		var is_opposing_motion: int = 0
		var max_speed_modified: float = speed_normalized[axis]
		var overall_influence: float = 0
		var excessive_speed_penalty: float = clamp(2 - (abs(speed_current.length()) / speed_default), 0, 1)
		
		if target_dir[axis] == 0:
			is_opposing_motion = 0
		else:
			is_opposing_motion = (target_dir[axis] == motion_dir[axis])
		
		overall_influence += INFLUENCE_BASE
		overall_influence += -AGILITY_MOD + (agility * AGILITY_MOD)
		overall_influence += is_opposing_motion * OPPOSING_MOTION_MOD
		overall_influence *= 1 - (EXCESSIVE_SPEED_MULTIPLIER - (EXCESSIVE_SPEED_MULTIPLIER * excessive_speed_penalty))
		speed_current[axis] = lerp(speed_current[axis], max_speed_modified, overall_influence)
	
	if speed_current.is_zero_approx():
		motion_dir = Vector2()
	else:
		motion_dir = speed_current.sign()


func move_and_turn(target_dir: Vector2, percentage_of_default: float = 1.0) -> void:
	move(target_dir, percentage_of_default)
	
	if not speed_current.is_zero_approx():
		look_angle = speed_current.angle()


# Effectively move(), but without the acceleration or, if called every frame instead of move(), deceleration.
func launch(target_dir: Vector2, percentage_of_default: float = 1.0) -> void:
	var speed_normalized: Vector2 = target_dir.normalized() * (speed_default * percentage_of_default)
	speed_current = speed_normalized
	move(target_dir, percentage_of_default)


func launch_and_turn(target_dir: Vector2, percentage_of_default: float = 1.0) -> void:
	var speed_normalized: Vector2 = target_dir.normalized() * (speed_default * percentage_of_default)
	speed_current = speed_normalized
	move_and_turn(target_dir, percentage_of_default)



func get_current_to_default_speed_ratio() -> float:
	if is_zero_approx(speed_current.length()) or is_zero_approx(speed_default):
		return 0.0
	
	return speed_current.length() / speed_default


func get_speed_dir() -> float:
	return speed_current.angle()


func get_movement_inputs() -> Vector2:
	return _movement_inputs
