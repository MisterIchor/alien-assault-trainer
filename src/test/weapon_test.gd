extends Node2D



func _ready() -> void:
	$Item.set_template(preload("res://src/ent/item/template/item_default.tres"))


func _input(event: InputEvent) -> void:
	if Input.is_action_pressed("primary"):
		$Item.use("primary")
