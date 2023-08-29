extends MultiplayerSpawner

@export var bullet_scene: PackedScene
@export var bullet_spawn: Node2D


func _ready() -> void:
#	set_multiplayer_authority(1)
	if not bullet_scene:
		return
	add_spawnable_scene(bullet_scene.resource_path)


func fire() -> void:
	fire_sever.rpc_id(1, bullet_spawn.get_global_mouse_position())


@rpc("any_peer", "call_local")
func fire_sever(target: Vector2) -> void:
	if not bullet_scene or not bullet_spawn:
		return
	var bullet = bullet_scene.instantiate()
	add_child(bullet, true)
	bullet.global_position = bullet_spawn.global_position
	bullet.rotation = bullet_spawn.global_position.direction_to(target).angle()
