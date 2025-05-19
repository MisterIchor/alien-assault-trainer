extends LineEdit

func _ready() -> void:
	text_submitted.connect(_on_text_submitted)
	focus_exited.connect(_on_focus_exited)



func _gui_input(event: InputEvent) -> void:
	accept_event()


func _on_text_submitted(_text: String) -> void:
	hide()
	clear()


func _on_focus_exited() -> void:
	hide()
	clear()
