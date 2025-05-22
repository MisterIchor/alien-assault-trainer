@tool
class_name AudioEmitter
extends Node

## Versatile audio player with support for audio banks.
##
## AudioEmitter plays sounds organized into sound banks. These sound banks sorts sounds into AudioStreamRandomizers,
## so sounds are played randomly. More information about that can be found in sound_bank.gd. 
##[br][br]
## You can use AudioEmitter as a regular AudioPlayer though the play_sound functions. Alternatively,
## you can also connect signal from other Objects to AudioEmitter, so that when that signal is emitted,
## AudioEmitter will play a sound from the assigned category.
##[br][br]
## _tracked_signals is formatted as such:
##[codeblock]
##{
##    NodePath = {
##    signal_name = category_name
##    }
##}
##[/codeblock]
## Use the editor to add signals or use [method add_signal] to add them via script.
##[br][br]
## When a new entry is added to _tracked_signals, it gets the node from NodePath and 
## connects the signal signal_name to AudioEmitter. It will play a sound from category_name whenever the 
## signal is emitted from that node. In addition, you have the choice of playing a sound from any of the 
## three types of AudioStreamPlayers. If a sound is played because of a tracked signal, it will choose 
## a player appropriate for the type of node the signal comes from.
##[br][br]
## Once an AudioStreamPlayer is done playing, it will be freed.

enum ToolMode {ADD, REMOVE}

@export var sound_bank: SoundBank = load("res://src/ent/emitters/audio_emitter/sound_bank/sound_bank_default.tres")
@export var audio_bus: String = "Master"
@export var players_follow_parent_node: bool = false
@export var players_interruptible: bool = false

@export_storage var _tracked_signals: Dictionary[NodePath, Array] = {}
var _tool_mode: ToolMode = ToolMode.ADD
var _node_path: NodePath = NodePath()
var _signal_name: String = ""
var _add_signal_callable: Callable = add_signal
var _remove_signal_callable: Callable = remove_signal




func _ready() -> void:
	if Engine.is_editor_hint():
		AudioServer.bus_layout_changed.connect(notify_property_list_changed)
		AudioServer.bus_renamed.connect(notify_property_list_changed)



func _get_property_list() -> Array[Dictionary]:
	var property_list: Array[Dictionary] = []
	
	property_list.append({
		name = "Tracked Signals",
		type = TYPE_NIL,
		usage = PROPERTY_USAGE_GROUP,
		hint_string = "tracksig-"
	})
	
	property_list.append({
		name = "tracksig-tool_mode",
		type = TYPE_INT,
		hint = PROPERTY_HINT_ENUM,
		hint_string = JILibrary.convert_enum_keys_to_string(ToolMode)
	})
	
	property_list.append({
		name = "tracksig-node",
		type = TYPE_NODE_PATH,
		hint = PROPERTY_HINT_NODE_PATH_VALID_TYPES
	})
	
	property_list.append({
		name = "tracksig-signal",
		type = TYPE_STRING,
		hint = PROPERTY_HINT_ENUM,
		hint_string = _get_list_of_signals_as_string(get_node_or_null(_node_path))
	})
	
	property_list.append({
		name = "tracksig-signal_button",
		type = TYPE_CALLABLE,
		usage = PROPERTY_USAGE_EDITOR,
		hint = PROPERTY_HINT_TOOL_BUTTON,
		hint_string = "Add Signal" if _tool_mode == ToolMode.ADD else "Remove Signal"
	})
	
	for node_path in _tracked_signals:
		property_list.append({
			# Returns "Nodepath (name of script file)"
			name = str(node_path, " (", get_node(node_path).get_script().resource_path.get_file(), ")").replace("/", "\\"),
			type = TYPE_NIL,
			usage = PROPERTY_USAGE_SUBGROUP,
			hint_string = str("sigdict-", node_path.get_concatenated_names().replace("/", "\\"), ":")
		})
		
		for signal_dict in _tracked_signals[node_path]:
			property_list.append({
				name = _sigdict_get_formatted_string(node_path, signal_dict.signal.get_name()),
				type = TYPE_STRING
			})
	
	return property_list


func _set(property: StringName, value: Variant) -> bool:
	if property.begins_with("tracksig-"):
		var property_name: String = property.get_slice("-", 1)
		
		if property_name == "tool_mode":
			_tool_mode = value
			notify_property_list_changed()
			return true
		
		if property_name == "node":
			_node_path = value
			notify_property_list_changed()
			return true
		
		if property_name == "signal_button":
			if _tool_mode == ToolMode.ADD:
				_add_signal_callable = value
			
			if _tool_mode == ToolMode.REMOVE:
				_remove_signal_callable = value
			
			return true
		
		if property_name == "signal":
			_signal_name = value
			return true
	
	if property.begins_with("sigdict-"):
		var sigdict: Dictionary = _sigdict_convert_formatted_string_to_dict(property)
		
		for i in _tracked_signals[sigdict.node_path]:
			if sigdict.signal_name.match(i.signal.get_name()):
				i.category_name = value
				return true
	
	return false


func _get(property: StringName) -> Variant:
	if property.begins_with("tracksig-"):
		var property_name: String = property.get_slice("-", 1)
		
		if property_name == "tool_mode":
			return _tool_mode
		
		if property_name == "node":
			return _node_path
		
		if property_name == "signal_button":
			if _tool_mode == ToolMode.ADD:
				return _add_signal_callable.bind(_node_path, _signal_name, "")
			
			if _tool_mode == ToolMode.REMOVE:
				return _remove_signal_callable.bind(_node_path, _signal_name)
		
		if property_name == "signal":
			return _signal_name
	
	if property.begins_with("sigdict-"):
		var sigdict: Dictionary = _sigdict_convert_formatted_string_to_dict(property)
		
		for i in _tracked_signals[sigdict.node_path]:
			if sigdict.signal_name.match(i.signal.get_name()):
				return i.category_name
	
	return


func _property_can_revert(property: StringName) -> bool:
	if property.begins_with("tracksig-"):
		var property_name: String = property.get_slice("-", 1)
		
		if property_name == "node":
			return true
		
		if property_name == "signal":
			return true
	
	if property.begins_with("sigdict-"):
		var sigdict: Dictionary = _sigdict_convert_formatted_string_to_dict(property)
		return is_signal_tracked(sigdict.node_path, sigdict.signal_name)
	
	return false


func _property_get_revert(property: StringName) -> Variant:
	if property.begins_with("tracksig-"):
		var property_name: String = property.get_slice("-", 1)
		
		if property_name == "node":
			return NodePath()
		
		if property_name == "signal":
			if not _node_path.is_empty():
				return get_node(_node_path).get_signal_list()[0].name
			
			return ""
	
	if property.begins_with("sigdict-"):
		var sigdict: Dictionary = _sigdict_convert_formatted_string_to_dict(property)
		
		if is_signal_tracked(sigdict.node_path, sigdict.signal_name):
			return ""
	
	return



func _add_player(player) -> void:
	return


func _get_list_of_signals_as_string(node: Node) -> String:
	if not node:
		return ""
	
	var signal_list: PackedStringArray = []
	
	for i in node.get_signal_list():
		if not i.name.begins_with("_"):
			signal_list.append(i.name)
	
	return ",".join(signal_list)



func _connect_signal(from_node: String, signal_name: String) -> void:
	var node: Node = get_node_or_null(from_node)
	var call: Callable = JILibrary.get_signal_callable_unbinded(node, signal_name, _on_tracked_signal_emitted)

	if not node:
		return
	
	node.connect(signal_name, call.bind(from_node, signal_name))


func _sigdict_convert_formatted_string_to_dict(property_name: String) -> Dictionary:
	var node_path_signal_arr: Array = property_name.trim_prefix("sigdict-").split(":")
	
	node_path_signal_arr[0] = node_path_signal_arr[0].replace("\\", "/")
	node_path_signal_arr[0] = NodePath(node_path_signal_arr[0])
	return {node_path = node_path_signal_arr[0], signal_name = node_path_signal_arr[1]}


func _sigdict_get_formatted_string(node_path: NodePath, signal_name: String) -> String:
	var node_path_str: String = node_path.get_concatenated_names()
	return str("sigdict-", node_path_str.replace("/", "\\"), ":", signal_name)


func add_signal(from_node: NodePath, signal_name: String, category_to_play: String) -> void:
	if is_signal_tracked(from_node, signal_name):
		return
	
	var node: Node = get_node_or_null(from_node)
	
	if not node:
		printerr("AudioEmitter: node at path %s does not exist." % [from_node])
		return
	
	if not node.has_signal(signal_name):
		printerr("AudioEmitter: signal %s does not exists in node at path %s." % [signal_name, from_node])
		return
	
	if not _tracked_signals.get(from_node):
		print(from_node)
		_tracked_signals[from_node] = []
	
	if not is_node_ready():
		await ready
	
	var new_signal: Dictionary = {
		"signal": Signal(node, signal_name),
		"category_name": category_to_play,
		"callable": JILibrary.get_signal_callable_unbinded(node, signal_name, _on_tracked_signal_emitted)
	}
	
	new_signal.signal.connect(new_signal.callable)
	_tracked_signals[from_node].append(new_signal)
	notify_property_list_changed()


func remove_signal(from_node: NodePath, signal_name: String) -> void:
	if not is_signal_tracked(from_node, signal_name):
		return
	
	for i in _tracked_signals[from_node]:
		if signal_name.matchn(i.signal.get_name()):
			i.signal.disconnect(i.callable)
			_tracked_signals[from_node].erase(i)
			notify_property_list_changed()
			return
	
	printerr("AudioEmitter: could not find signal %s in node %s in list of tracked signals." % [signal_name, from_node])


func is_signal_tracked(from_node: NodePath, signal_name: String) -> bool:
	if not is_node_tracked(from_node):
		printerr("AudioEmitter: node %s does not exist in list of tracked signals." % [from_node])
		return false
	
	for i in _tracked_signals.get(from_node):
		if signal_name.matchn(i.signal.get_name()):
			return true
	
	return false


func is_node_tracked(node: NodePath) -> bool:
	return not _tracked_signals.get(node) == null


func play_sound(category: String, pitch_range: float = 1.0) -> void:
	var audio_stream: AudioStreamRandomizer = _get_audio_stream_randomizer(category)
	
	if not audio_stream:
		return
	
	var player: AudioStreamPlayer = AudioStreamPlayer.new()
	
	player.finished.connect(_on_AudioPlayer_finished.bind(player), CONNECT_DEFERRED)
	player.stream = audio_stream
	player.bus = audio_bus
	add_child(player)
	player.play()


func play_sound_2D(position: Vector2, category: String, pitch_range: float = 1.0) -> void:
	var audio_stream: AudioStreamRandomizer = _get_audio_stream_randomizer(category)
	
	if not audio_stream:
		return
	
	var player: AudioStreamPlayer2D = AudioStreamPlayer2D.new()
	
	player.finished.connect(_on_AudioPlayer_finished.bind(player), CONNECT_DEFERRED)
	player.stream = audio_stream
	player.position = position
	player.bus = audio_bus
	add_child(player)
	player.play()


func play_sound_3D(position: Vector3, category: String, pitch_range: float = 1.0) -> void:
	var audio_stream: AudioStreamRandomizer = _get_audio_stream_randomizer(category)
	
	if not audio_stream:
		return
	
	var player: AudioStreamPlayer3D = AudioStreamPlayer3D.new()
	
	player.finished.connect(_on_AudioPlayer_finished.bind(player), CONNECT_DEFERRED)
	player.stream = audio_stream
	player.position = position
	player.bus = audio_bus
	add_child(player)
	player.play()



func _get_audio_stream_randomizer(category_name: String) -> AudioStreamRandomizer:
	if not sound_bank:
		return null
	
	var category_to_play: AudioStreamRandomizer = sound_bank.get_category(category_name)
	
	if not category_to_play:
		printerr("AudioEmitter: Sound bank category not found: %s" % category_name)
	
	return category_to_play


func _on_AudioPlayer_finished(player: Node) -> void:
	player.queue_free()


func _on_tracked_signal_emitted(node_path: NodePath, signal_name: String) -> void:
	var node: Node = get_node_or_null(node_path)
	
	if not node:
		return
	
	#if node is Node2D:
		#play_sound_2D(node.position, _tracked_signals[node_path][signal_name])
	#elif node is Node3D:
		#play_sound_3D(node.position, _tracked_signals[node_path][signal_name])
	#else:
		#play_sound(_tracked_signals[node_path][signal_name])
