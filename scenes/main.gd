extends Node2D

@export var player_scene: PackedScene
@onready var players: Node2D = $Players
@onready var spawn: Node2D = $Spawn

@export var player_a_scene : PackedScene
@export var player_b_scene : PackedScene


func _ready() -> void:
#	if multiplayer.is_server():
	Game.sort_players()
	for i in Game.players.size():
		var player_data = Game.players[i]
		var player
		if player_data.role == Statics.Role.ROLE_A:
			if player_a_scene:
				player = player_a_scene.instantiate()
		elif player_data.role == Statics.Role.ROLE_B:
			if player_b_scene:
				player = player_b_scene.instantiate()

		if not player:
			continue
#		var player = player_scene.instantiate()
#		player.name = str(player_data.id)
		players.add_child(player)
		player.setup(player_data)
		player.global_position = spawn.get_child(i).global_position
		


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
