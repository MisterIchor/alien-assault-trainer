extends Node2D

var is_procedural_anim_enabled: bool = false:
	set(value):
		is_procedural_anim_enabled = value
		set_process(is_procedural_anim_enabled)
var procedural_anim_speed: Dictionary = {
	head = 1.0,
	body_upper = 1.0,
	body_lower = 1.0,
}
var look_angle: float = 0.0
var head_angle_limit: float = 55.0
var head_look_at: Vector2 = Vector2()

@onready var body_upper: Node2D = $BodyUpper
@onready var body_lower: Node2D = $BodyLower
@onready var arm_left: Node2D = $ArmLeft
@onready var arm_right: Node2D = $ArmRight
@onready var head: Sprite2D = $BodyUpper/Head
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var personal_space_ray: RayCast2D = $BodyUpper/PersonalSpaceRay
@onready var item_pivot_point: Marker2D = $BodyUpper/ItemPivotPoint



func _process(delta: float) -> void:
	body_upper.rotation = lerp_angle(body_upper.rotation, look_angle, procedural_anim_speed.body_upper)
	body_lower.rotation = lerp_angle(body_lower.rotation, look_angle, procedural_anim_speed.body_lower)
	
	var body_vec_forward: Vector2 = Vector2.from_angle(body_upper.rotation)
	var body_vec_side: Vector2 = Vector2.from_angle(body_upper.rotation + (TAU / 4))
	var dir_to_poi: Vector2 = position.direction_to(head_look_at)
	var dot_forward: float = body_vec_forward.dot(dir_to_poi)
	var dot_side: float = body_vec_side.dot(dir_to_poi)
	
	if head_look_at == Vector2():
		head.global_rotation = lerp_angle(head.global_rotation, look_angle, procedural_anim_speed.head)
		return
	
	if dot_forward < clamp(1 - (head_angle_limit / 90.0), 0, 1):
		var angle_limit: float = deg_to_rad(head_angle_limit) * sign(dot_side)
		head.rotation = lerp_angle(head.rotation, angle_limit, procedural_anim_speed.head)
		return
	
	head.global_rotation = lerp_angle(head.global_rotation, dir_to_poi.angle(), procedural_anim_speed.head)




func play_animation(anim_name: String, speed: float = 1.0) -> void:
	animation_player.play(anim_name)
	animation_player.speed_scale = speed


func reset_animation() -> void:
	animation_player.play("RESET")



func set_personal_space_length(new_length: float) -> void:
	personal_space_ray.target_position = Vector2(new_length, 0)



func _on_item_added(item: Item, _idx: int) -> void:
	item.reparent(item_pivot_point, false)
