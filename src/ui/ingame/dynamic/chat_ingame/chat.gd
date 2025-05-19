extends Control

const MESSAGE_INGAME: PackedScene = preload("res://src/ui/ingame/dynamic/message_ingame/message_ingame.tscn")

var unit: Unit = null
@onready var message_box: LineEdit = $MessageBox
@onready var messages: Control = $Messages



func _ready() -> void:
	message_box.text_submitted.connect(_on_MessageBox_text_submitted)
	message_box.focus_exited.connect(_on_MessageBox_focus_exited)


func _sort_messages() -> void:
	var y_pos: float = 0
	
	for i: Control in messages.get_children():
		i.position = -i.size / 2
		i.position.y = y_pos
		y_pos -= i.size.y


func _unhandled_input(event: InputEvent) -> void:
	if message_box.visible:
		if event is InputEventMouseButton:
			if not message_box.get_global_rect().has_point(get_global_mouse_position()):
				message_box.release_focus()
		
		accept_event()
	
	if event.is_action_pressed("chat_local"):
		open_message_box()
		accept_event()
		
		if unit:
			unit.movement.cancel_movement_inputs()
	
	if event.is_action_pressed("ui_cancel"):
		message_box.release_focus()
		accept_event()



func open_message_box() -> void:
	message_box.show()
	message_box.grab_focus()



func _on_MessageBox_text_submitted(text: String) -> void:
	var new_message: Control = MESSAGE_INGAME.instantiate()
	
	new_message.message = text
	new_message.color = Color.WHITE
	new_message.expiration_time = 1
	new_message.tree_exited.connect(_sort_messages)
	messages.add_child(new_message)
	new_message.start()
	message_box.hide()
	message_box.clear()
	_sort_messages()


func _on_MessageBox_focus_exited() -> void:
	message_box.hide()
	message_box.clear()
