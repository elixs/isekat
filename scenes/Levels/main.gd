extends Node2D

@export var player_a_scene: PackedScene
@export var player_b_scene: PackedScene
@onready var players: Node2D = $Players
@onready var spawn: Node2D = $Spawn


func _ready() -> void:
	Game.sort_players()
	for i in Game.players.size():
		var player_data = Game.players[i]
		var player
		if player_data.role == Game.Role.ROLE_A:
			player = player_a_scene.instantiate()
		else:
			player = player_b_scene.instantiate()
		players.add_child(player)
		player.setup(player_data)
		player.global_position = spawn.get_child(i).global_position
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
