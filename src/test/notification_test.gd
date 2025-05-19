extends Node2D

enum Oof {TOMMY, TALERICO}

var e = load("res://src/global/target_initializer/new_resource.tres")
var a = load("res://src/global/target_initializer/new_resource.tres")
var test: Dictionary = {
	deez = "A",
	nuts = "E"
}
var blow_me: int = 1337
var oof:int = 0
@onready var dict: Dictionary = {
	get_node("Node") : 0
}

func _ready() -> void:
	e.target = self
	print(dict)
	get_node("Node").free()
	print(dict)
