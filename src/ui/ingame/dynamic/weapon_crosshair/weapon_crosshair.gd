@tool
extends Control

const ACC_GRADIENT_COLORS_DEFAULT: PackedColorArray = [Color(Color.WHITE, 0.0), Color.WHITE, Color(Color.WHITE, 0)]

@export_group("Accuracy Indicator")
@export var accuracy_high_offset: float = 0.126:
	set(value):
		accuracy_high_offset = value
		_update_accuracy_indicator()
@export var accuracy_high_interval: float = 0.05:
	set(value):
		accuracy_high_interval = value
		_update_accuracy_indicator()
@export var accuracy_low_interval: float = 0.069:
	set(value):
		accuracy_low_interval = value
		_update_accuracy_indicator()
@export var accuracy_low_ring_transparency: float = 0.3:
	set(value):
		accuracy_low_ring_transparency = value
		_update_accuracy_indicator()
@export var accuracy_low_offset: float = 0.083:
	set(value):
		accuracy_low_offset = value
		_update_accuracy_indicator()
@export var accuracy: float = 1.0:
	set(value):
		accuracy = value
		_update_accuracy_indicator()
@export_group("Ammo Indicator")
@export var ammo_percentage: float = 1.0:
	set = set_ammo_percentage
@export var ammo_colors: PackedColorArray = []:
	set = set_ammo_colors
@export var blink_time: float = 0.5:
	set = set_blink_time

var unit: Unit = null:
	set = set_unit

var _gradient_accuracy: Gradient = Gradient.new()
var _gradient_ammo: Gradient = Gradient.new()
var _is_accuracy_update_queued: bool = false

@onready var accuracy_indicator: TextureRect = $AccuracyIndicator
@onready var ammo_indicator: TextureRect = $AmmoIndicator
@onready var blinker_timer: Timer = $BlinkerTimer



func _init() -> void:
	_gradient_accuracy.interpolation_mode = Gradient.GRADIENT_INTERPOLATE_CUBIC
	_gradient_ammo.interpolation_mode = Gradient.GRADIENT_INTERPOLATE_CUBIC


func _ready() -> void:
	accuracy_indicator.texture.gradient = _gradient_accuracy
	blinker_timer.timeout.connect(_on_BlinkerTimer_timeout)
	
	if not Engine.is_editor_hint():
		Input.mouse_mode = Input.MOUSE_MODE_HIDDEN


func _update_accuracy_indicator() -> void:
	if not is_inside_tree():
		await ready
	
	if _is_accuracy_update_queued:
		return
	
	_is_accuracy_update_queued = true
	await get_tree().process_frame
	
	var colors: PackedColorArray = ACC_GRADIENT_COLORS_DEFAULT.duplicate()
	var offsets: PackedFloat32Array = []
	var interval_step: float = 0
	var offset_step: float = 0
	var color_step: float = 0
	
	interval_step += accuracy_high_interval - accuracy_low_interval
	interval_step *= 1 - accuracy
	interval_step += accuracy_high_interval
	
	offset_step += accuracy_low_offset - accuracy_high_offset
	offset_step *= 1 - accuracy
	offset_step += accuracy_high_offset
	
	color_step -= 1 - accuracy
	color_step *= 1 - accuracy_low_ring_transparency
	color_step += 1
	
	colors[0] = Color(Color.WHITE, accuracy)
	colors[1] = Color(Color.WHITE, color_step)
	
	for i in 3:
		offsets.append((interval_step * i) + offset_step)
	
	_gradient_accuracy.colors = []
	_gradient_accuracy.offsets = []
	
	for i in 3:
		_gradient_accuracy.add_point(offsets[i], colors[i])
	
	_is_accuracy_update_queued = false



func set_unit(new_unit: Unit) -> void:
	unit = new_unit


func set_ammo_percentage(new_percentage: float) -> void:
	if not is_inside_tree():
		await ready
	
	ammo_percentage = new_percentage
	ammo_indicator.self_modulate = _gradient_ammo.sample(ammo_percentage)
	
	if is_zero_approx(ammo_percentage):
		blinker_timer.start()
	elif not blinker_timer.is_stopped():
		blinker_timer.stop()
		ammo_indicator.visible = true


func set_ammo_colors(colors: PackedColorArray) -> void:
	ammo_colors = colors
	_gradient_ammo.colors = []
	_gradient_ammo.offsets = []
	
	if ammo_colors.is_empty():
		return
	
	var interval: float = 1.0 / colors.size()
	
	for i in colors.size():
		_gradient_ammo.add_point(interval * i, ammo_colors[i])


func set_blink_time(new_time: float) -> void:
	if not is_inside_tree():
		await ready
	
	blink_time = new_time
	blinker_timer.wait_time = blink_time



func _on_BlinkerTimer_timeout() -> void:
	ammo_indicator.visible = not ammo_indicator.visible
