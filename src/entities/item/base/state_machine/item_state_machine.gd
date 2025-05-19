class_name ItemStateMachine
extends Node

var state: ItemState = null:
	set = set_state
@onready var active: bool = false:
	set = set_active

"""
Unlike unit_state_machine.gd, item_state_machine.gd is designed with the idea that
each state is an interaction that the unit can perform on the item rather than a complex web
of states that transition between each other. As such, states can only be changed when state = Idle.
When a state emits the finished signal, the machine immediately goes back to the idle state.

In addition, item_state_machine.gd requires three states to be initialized: Idle, Primary, and Secondary.
More interactions can be added under any name, but under the scope of this project, the only other interaction
the player can perform is "reload".

Quick note: ItemState._hit() and ItemState._drop() are in addition to the default
behavior that occurs, rather than a replacement.

States can extend states_default/item_state_empty.gd if an interaction is not desired.
"""



#func _process(delta: float) -> void:
	#state._handle_process(delta)


#func _physics_process(delta: float) -> void:
	#state._handle_physics_process(delta)


func _initialize_states(states: Dictionary) -> void:
	var states_required: PackedStringArray = [
		"idle",
		"primary",
		"secondary"
	]
	print("%s: Checking for required states..." % get_parent().name)
	
	for i: String in states_required:
		if not states.get(i):
			printerr("%s: %s state not found, shutting down..." % [get_parent().name, i.capitalize()])
			active = false
			return
	
	print("%s: Required states found, initializing states..." % get_parent().name)
	
	for i: String in states.keys():
		var new_state: ItemState = states[i].new()
		new_state.item = get_parent()
		add_child(new_state)
		new_state.name = i.capitalize()
	
	print("%s: State initialization complete, lets do this!" % get_parent().name)
	state = get_node("Idle")



func set_state(new_state: ItemState) -> void:
	if state:
		state._exit()
		state.finished.disconnect(_on_State_finished)
	
	state = new_state
	
	if state:
		state.finished.connect(_on_State_finished)
		state._enter()


func set_active(value: bool) -> void:
	active = value
	set_process(active)
	set_physics_process(active)



func _on_State_finished() -> void:
	state = get_node("Idle")


func _on_item_hit(item: Item, from: Unit) -> void:
	state._hit()


func _on_item_dropped(item: Item) -> void:
	state._drop()
	set_state(get_node("Idle"))


func _on_item_used(item: Node, _item_type: String, interaction_type: String) -> void:
	if not state.name == "Idle":
		return
	
	var new_state: ItemState = get_node_or_null(interaction_type.capitalize())
	
	if new_state:
		set_state(get_node(interaction_type.capitalize()))


func _on_body_entered(body: Node) -> void:
	state._handle_collision(body)
