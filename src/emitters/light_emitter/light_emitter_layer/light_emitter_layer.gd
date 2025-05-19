class_name LightEmitterLayer
extends PointLight2D

const LIGHT_ROTATION_Z_POSITION_ADJUST: float = 200.0
const LIGHT_ROTATION_Z_SCALE_X: float = 1.0
const LIGHT_ROTATION_Z_SCALE_Y: float = 1.0
const LIGHT_ROTATION_Z_FADE_OUT_ANGLE_MIN: float = 45.0
const LIGHT_ROTATION_Z_FADE_OUT_ANGLE_MAX: float = 90.0

enum RotationAnimBehavior {SPIN, PING_PONG}

var pos_offset: Vector2 = Vector2():
	set(value):
		pos_offset = value
		_update_transform()
var rotation_y_offset: float = 0.0
var rotation_y_limit: float = PI
var rotation_y_behavior: RotationAnimBehavior = RotationAnimBehavior.SPIN:
	set(value):
		rotation_y_behavior = value
		_rotation_y_dir = 1
var rotation_z_offset: float = 0.0
var rotation_z_limit: float = PI
var rotation_z_behavior: RotationAnimBehavior = RotationAnimBehavior.SPIN:
	set(value):
		rotation_z_behavior = value
		_rotation_y_dir = 1
		_rotation_z_dir = 1

# Internal values for rotation. Mainly relevent when rotation_*_behavior == RotationAnimBehavior.PING_PONG.
var _rotation_z: float = 0.0
var _rotation_y: float = 0.0
var _rotation_y_dir: int = 1
var _rotation_z_dir: int = 1



func _update_transform() -> void:
	var rotation_z_percentage: float = (_rotation_z + rotation_z_offset) / PI
	var easing: float = ease(abs(rotation_z_percentage) / 1.0, 0.4)
	scale.x = 1 + (LIGHT_ROTATION_Z_SCALE_X * easing)
	scale.y = 1 + (LIGHT_ROTATION_Z_SCALE_Y * easing)
	color.a = 1 - easing
	position = Vector2()
	position.x = LIGHT_ROTATION_Z_POSITION_ADJUST * (sign(rotation_z_percentage) * easing)
	position = position.rotated(_rotation_y + rotation_y_offset)
	position += pos_offset
	rotation = _rotation_y + rotation_y_offset



func increment_rotation_y(by: float) -> void:
	_rotation_y += by * _rotation_y_dir
	
	match rotation_y_behavior:
		RotationAnimBehavior.SPIN:
			_rotation_y = wrapf(_rotation_y, -PI + (PI - rotation_y_limit), PI - (PI - rotation_y_limit))
		RotationAnimBehavior.PING_PONG:
			_rotation_y = clamp(_rotation_y, -PI + (PI - rotation_y_limit), PI - (PI - rotation_y_limit))
			
			if is_equal_approx(abs(_rotation_y), rotation_y_limit):
				_rotation_y_dir *= -1
	
	_update_transform()


func increment_rotation_z(by: float) -> void:
	_rotation_z += by * _rotation_z_dir
	
	match rotation_z_behavior:
		RotationAnimBehavior.SPIN:
			_rotation_z = wrapf(_rotation_z, -PI + (PI - rotation_z_limit), PI - (PI - rotation_z_limit))
		RotationAnimBehavior.PING_PONG:
			_rotation_z = clamp(_rotation_z, -PI + (PI - rotation_z_limit), PI - (PI - rotation_z_limit))
			
			if is_equal_approx(abs(_rotation_z), rotation_z_limit):
				_rotation_z_dir *= -1
	
	_update_transform()

func reset_rotation() -> void:
	_rotation_y = 0.0
	_rotation_z = 0.0
	_rotation_y_dir = 1
	_rotation_z_dir = 1
	_update_transform()
