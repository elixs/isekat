extends Node


var player_index = 1

@onready var timer = $Timer

func _ready():
	
	if is_multiplayer_authority():
	
		for test_player in Game.test_players:
			var player = Statics.PlayerData.new(
				test_player.id,
				test_player.name,
				test_player.role
			)
			Game.players.push_back(player)
	
	multiplayer.peer_connected.connect(_on_peer_connected)
	
	if not try_host():
		try_join()
	
	timer.timeout.connect(start_game)

func try_host() -> bool:
	var peer = ENetMultiplayerPeer.new()
	var err = peer.create_server(Statics.PORT, Statics.MAX_PLAYERS)
	if err:
		Debug.dprint("Host Error: %d" %err)
	return not err


func try_join() -> bool:
	var peer = ENetMultiplayerPeer.new()
	var err = peer.create_client("localhost", Statics.PORT)
	if err:
		Debug.dprint("Join Error: %d" %err)
	return not err


func _on_peer_connected(id: int) -> void:
	if is_multiplayer_authority():
		Debug.dprint("peer_connected %d" % id)
		Game.players[player_index].id = id
		send_player_data_id.rpc(player_index, id)
		player_index += 1

@rpc("reliable")
func send_player_data_id(player_index, id):
	Game.players[player_index].id = id


func start_game() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")
