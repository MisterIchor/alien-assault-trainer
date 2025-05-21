class_name AudioEmitterPlayer2D
extends AudioStreamPlayer2D

var radius: float = 2000.0
@onready var collision_shape_2d: CircleShape2D = $Area2D/CollisionShape2D.shape



func _init(sound_radius: float, audio_bus: String) -> void:
	radius = sound_radius
	bus = audio_bus


func _ready() -> void:
	max_distance = radius
	collision_shape_2d.radius = radius
