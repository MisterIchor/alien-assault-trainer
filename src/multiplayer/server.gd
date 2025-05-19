extends Node

signal player_connected(peer_id, player_info)
signal player_disconnected(peer_id)
signal server_disconnected
signal message_transmitted(message)

const DEFAULT_SERVER_IP: String = "127.0.0.1"
const PORT: int = 7000

var players: Array = []
var players_max: int = 4
var is_cheats_enabled: bool = false
var log: Dictionary = {
	chat = []
}



#func _ready() -> void:
	#multiplayer.peer_connected.connect(_on_peer_connected)
	#multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	#multiplayer.server_disconnected.connect(_on_server_disconnected)
