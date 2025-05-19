extends RichTextLabel

@export var message: String = "This is a test."
@export var color: Color = Color()
@export var text_speed: float = 0.3
@export var fade_in_time: float = 0.1
@export var fade_out_time: float = 0.1
@export var expiration_time: float = 1.0

var _tween: Tween = null
var _is_message_playing: bool = false



func _update_text() -> void:
	var color_hex: String = PackedByteArray([color.r8, color.g8, color.b8]).hex_encode()
	var prefix: String = str("[color=#", color_hex, "]")
	var message_size: Vector2 = Vector2()
	var expiration_timer: SceneTreeTimer = null
	
	text = message
	message_size = get_minimum_size()
	text = ""
	size = message_size
	_tween = create_tween()
	_tween.tween_property(self, "self_modulate", Color(Color.WHITE, 1.0), fade_in_time)
	text = str(prefix, "[/color]")
	
	for i in message.length():
		text = text.insert(prefix.length() + i, message[i])
		await get_tree().create_timer(text_speed).timeout
	
	if _tween.is_running():
		await _tween.finished
	
	expiration_timer = get_tree().create_timer(expiration_time)
	expiration_timer.timeout.connect(_on_ExpirationTimer_timeout)



func start() -> void:
	if not _is_message_playing:
		_update_text()
		_is_message_playing = true



func _on_ExpirationTimer_timeout() -> void:
	_tween = create_tween()
	_tween.tween_property(self, "self_modulate", Color(Color.WHITE, 0.0), fade_out_time)
	await _tween.finished
	queue_free()
