@tool
class_name RadialDetection
extends Area2D
## An [Area2D] that returns the node closest to the center. Includes settings for putting
## on cooldown if they are the closest for too long and "line-of-sight" blocking, as well as 
## an exceptions list akin to those found on [PhysicsBody2D] objects.
##
## [RadialDetection] uses [signal Area2D.body_entered] and [signal Area2D.body_exited] to keep tracked
## of objects in range as determined by [member CollisionObject2D.collision_mask].
##[br][br]
## When [member cooldown_enabled] is set to true, cooldown is enabled. Each time the closest object
## is changed to a new object, the cooldown timer resets. If the cooldown timer reaches 0, the closest
## object is added to a cooldown list and [method add_exception] is called on it. Once the object is out of
## [member range], it is removed from the cooldown list and [method remove_exception] is called on it.
##[br][br]
## When [member can_be_blocked] is enabled, a new [RayCast2D] is created to detect collision from the
## center of [RadialDetection] to the object's [member Node2D.global_position] as determined by the
## collision mask in [member blocked_by]. If a collision is detected, the object is ignored.
##[br][br]
## [b]Important:[/b] Unlike objects added to [member _exceptions] or objects on cooldown, objects that 
## are blocked are still being tracked. Keep this in mind if you are using [method get_tracked_in_range].

## Emits when a new node is set as the closest node.
signal new_closest_tracked(tracked)
## Emits if the lists of tracked nodes is empty.
signal tracked_empty

## Range of the [CollisionShape2D] radius used by [RadialDetection]
@export var range: float = 40.0:
	set = set_range
## Any nodes in this array will not be add to the list of tracked objects. If adding/removing 
## exceptions in real-time, use [method add_exception] and [method remove_exception].
@export var _exceptions: Array[Node] = []
@export_group("Cooldown")
## If enabled, adds a [Timer] that, upon [signal Timer.timeout], will add the closest tracked node
## to the cooldown pool. All objects on cooldown will be ignored until they leave the detection radius.
@export var cooldown_enabled: bool = false:
	set = set_cooldown_enabled
## How much time that needs to elaspe before the closest object gets added to the cooldown pool.
@export var cooldown_timer_wait_time: float = 3.0:
	set(value):
		cooldown_timer_wait_time = value
		
		if _cooldown_timer:
			_cooldown_timer.wait_time = value
@export_group("Block")
## If enabled, creates a [RayCast2D] Node that uses the collision mask in [member blocked_by]
## to determine if a node is blocked and should not be consided the closest.
@export var can_be_blocked: bool = false:
	set = set_can_be_blocked
## Collision mask for the [RayCast2D] enabled by [member can_be_blocked]
@export_flags_2d_physics var blocked_by: int = 0:
	set = set_blocked_by

var _on_cooldown: Array[Node] = []
var _tracked_in_range: Dictionary = {}
var _closest: Node2D = null:
	set = _set_closest
var _collision_ray: RayCast2D = null
var _cooldown_timer: Timer = null

@onready var _collision_shape_2d: CollisionShape2D = $CollisionShape2D



func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	_collision_shape_2d.shape = CircleShape2D.new()
	set_physics_process(false)


func _physics_process(_delta: float) -> void:
	var old_closest: Node = _closest
	_closest = null
	
	for i in _tracked_in_range.keys():
		_tracked_in_range[i] = i.global_position.distance_squared_to(global_position)
	
	for i in _tracked_in_range:
		if can_be_blocked:
			_collision_ray.target_position = to_local(i.global_position)
			_collision_ray.force_raycast_update()
			
			if _collision_ray.is_colliding():
				continue
		
		if not _closest:
			_closest = i
			continue
		
		if _tracked_in_range[i] < _tracked_in_range[_closest]:
			_closest = i
	
	if cooldown_enabled:
		if _closest:
			if not _closest == old_closest: 
				_cooldown_timer.start()
		else:
			_cooldown_timer.stop()


func _set_closest(new_closest: Node2D) -> void:
	if new_closest == _closest:
		return
	
	_closest = new_closest
	new_closest_tracked.emit(_closest)


## Adds [param body] to the exceptions array. If successful, [param body] will be removed from the list
## of tracked nodes, and will set the closest node to null if [param body] is the closest node.
func add_exception(body: Node) -> void:
	if not body in _exceptions:
		_exceptions.append(body)
		_tracked_in_range.erase(body)
		
		if body == _closest:
			_closest = null

## Removes [param body] from [member _exceptions]. Will emit [signal body_entered] if [param body] is 
## detected in [method get_overlapping_bodies] to ensure that [param body] gets processed.
func remove_exception(body: Node) -> void:
	var body_in_exceptions: int = _exceptions.find(body)
	
	if body_in_exceptions:
		_exceptions.remove_at(body_in_exceptions)
		
		if body in get_overlapping_bodies():
			body_entered.emit(body)



func set_cooldown_enabled(value: bool) -> void:
	cooldown_enabled = value
	
	if Engine.is_editor_hint():
		return
	
	if cooldown_enabled:
		if not _cooldown_timer:
			_cooldown_timer = Timer.new()
			_cooldown_timer.wait_time = cooldown_timer_wait_time
			#_cooldown_timer.one_shot = true
			_cooldown_timer.timeout.connect(_on_CooldownTimer_timeout)
			add_child(_cooldown_timer)
	else:
		if _cooldown_timer:
			_cooldown_timer.queue_free()
		
		_on_cooldown.clear()


func set_can_be_blocked(value: bool) -> void:
	can_be_blocked = value
	
	if Engine.is_editor_hint():
		return
	
	if can_be_blocked:
		if not _collision_ray:
			_collision_ray = RayCast2D.new()
			_collision_ray.collision_mask = blocked_by
			add_child(_collision_ray)
	elif _collision_ray:
		_collision_ray.queue_free()


func set_blocked_by(new_mask: int) -> void:
	blocked_by = new_mask
	
	if Engine.is_editor_hint():
		return
	
	if _collision_ray:
		_collision_ray.collision_mask = blocked_by


func set_range(new_range: float) -> void:
		if not is_node_ready():
			await ready
		
		range = new_range
		(_collision_shape_2d.shape as CircleShape2D).radius = range


## Returns the closest node.
func get_closest() -> Node2D:
	return _closest

## Returns a list of objects on cooldown.
func get_cooldown_pool() -> Array[Node]:
	return _on_cooldown.duplicate()

## Returns a copy of [member exceptions].
func get_exceptions() -> Array[Node]:
	return _exceptions.duplicate()

## Returns a dictionary of all nodes being tracked. Dictionary consists of Node:float pairs, where float
## is the distance away from the center of [RadialDetection].
func get_tracked_in_range() -> Dictionary:
	return _tracked_in_range.duplicate()



func _on_body_entered(body: Node) -> void:
	if body in _exceptions:
		return
	
	_tracked_in_range.get_or_add(body, 0.0)
	
	if not is_physics_processing():
		set_physics_process(true)


func _on_body_exited(body: Node) -> void:
	_tracked_in_range.erase(body)
	
	if cooldown_enabled:
		var body_on_cooldown: int = _on_cooldown.find(body)
		
		if not body_on_cooldown == -1:
			_on_cooldown.remove_at(body_on_cooldown)
			remove_exception(body)
	
	if _tracked_in_range.is_empty():
		_closest = null
		
		if cooldown_enabled:
			_cooldown_timer.stop()
		
		if is_physics_processing():
			set_physics_process(false)


func _on_CooldownTimer_timeout() -> void:
	_on_cooldown.append(_closest)
	add_exception(_closest)
