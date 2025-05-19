class_name Projectile
extends RayCast2D

var force: float = 0.0
var direction: Vector2 = Vector2()
var height: float = 0.0
var damage: int = 15
var from: Unit = null:
	set(value):
		from = value
		
var active: bool = false:
	set = set_active

var _height_current: float = 0.0

@onready var sprite_2d: Sprite2D = $Sprite2D



func _ready() -> void:
	set_physics_process(false)


func _physics_process(delta: float) -> void:
	global_position += force * direction
	height += force
	
	var collider: Object = get_collider()
	
	if collider:
		if collider.has_method("hit"):
			collider.hit(damage, from)
			
			if collider is Unit:
				from.combat.last_attack_hit = collider
		
		queue_free()
	
	if height <= 0:
		queue_free()



func set_active(value: bool) -> void:
	active = value
	set_physics_process(value)
	collide_with_bodies = value
	rotation = direction.angle()
