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
## _signal_tracker is formatted as such:
##[codeblock]
##{
##    NodePath = {
##    signal_name = category_name
##    }
##}
##[/codeblock]
## Use the editor to add signals or use [method add_signal] to add them via script.
##[br][br]
## When a new entry is added to _signal_tracker, it gets the node from NodePath and 
## connects the signal signal_name to AudioEmitter. It will play a sound from category_name whenever the 
## signal is emitted from that node. In addition, you have the choice of playing a sound from any of the 
## three types of AudioStreamPlayers. If a sound is played because of a tracked signal, it will choose 
## a player appropriate for the type of node the signal comes from.
##[br][br]
## Once an AudioStreamPlayer is done playing, it will be freed.

@export var sound_bank: SoundBank = load("res://src/ent/emitters/audio_emitter/sound_bank/sound_bank_default.tres")
@export var audio_bus: String = "Master"
@export_group("Signal Tracker")
@export var _node_path: NodePath = NodePath()
@export var _signal_name: String = ""
@export var _category_to_play: String = ""
@export var _add_signal: bool = false:
	set(value):
		if value:
			_signal_tracker.get_or_add(_node_path, {})[_signal_name] = _category_to_play
			notify_property_list_changed()
			_signal_name = ""
			_category_to_play = ""
@export var _signal_tracker: Dictionary = {}




func _ready() -> void:
	if not _signal_tracker.is_empty():
		for path in _signal_tracker:
			for sig in _signal_tracker[path]:
				_connect_signal(path, sig)



func _add_player(player) -> void:
	return


func _connect_signal(from_node: String, signal_name) -> void:
	var node: Node = get_node_or_null(from_node)
	var call: Callable = JILibrary.get_signal_callable_unbinded(node, signal_name, _on_tracked_signal_emitted)

	if not node:
		return
	
	node.connect(signal_name, call.bind(from_node, signal_name))



func add_signal(from_node: NodePath, signal_name: String, category_to_play: String) -> void:
	_signal_tracker[from_node] = {signal_name = category_to_play}
	
	if not is_inside_tree():
		await ready
	
	_connect_signal(from_node, signal_name)


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
	
	if node is Node2D:
		play_sound_2D(node.position, _signal_tracker[node_path][signal_name])
	elif node is Node3D:
		play_sound_3D(node.position, _signal_tracker[node_path][signal_name])
	else:
		play_sound(_signal_tracker[node_path][signal_name])
