class_name ItemState
extends Node

signal finished

var item: Item = null
var _timer: SceneTreeTimer = null



func _enter() -> void:
	return


func _drop() -> void:
	return


func _hit() -> void:
	return


func _interrupt() -> void:
	return


func _exit() -> void:
	return


func _handle_process(delta: float) -> void:
	return


func _handle_physics_process(delta: float) -> void:
	return


func _handle_collision(body: Node) -> void:
	return


func _handle_timeout() -> void:
	return



func start_timer(wait_time: float) -> void:
	if not is_inside_tree():
		await ready
	
	_timer = get_tree().create_timer(wait_time, false, true)
	_timer.timeout.connect(_handle_timeout)
