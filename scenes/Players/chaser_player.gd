class_name ChaserPlayer
extends CharacterBody2D

var max_speed = 200
var jump_speed = 200
var acceleration = 1000
var gravity = 400

@onready var camera_2d: Camera2D = $Camera2D
@onready var pivot: Node2D = $Pivot

func _physics_process(delta: float) -> void:
#	Debug.dprint(velocity)
	
	if not is_on_floor():
		velocity.y += gravity * delta
	
	if is_multiplayer_authority():
		var move_input = Input.get_axis("move_left", "move_right")
		
		if Input.is_action_just_pressed("jump"):
			jump.rpc()
#			jump()
		
		velocity.x = move_toward(velocity.x, max_speed * move_input, acceleration * delta)
		
		send_info.rpc(global_position, velocity)
#	else:
#		pass

	move_and_slide()
	if velocity.x != 0:
		pivot.scale.x = sign(velocity.x)
	
	
	
@rpc("unreliable_ordered")
func send_info(pos: Vector2, vel: Vector2) -> void:
	global_position = lerp(global_position, pos, 0.5)
	velocity = lerp(velocity, vel, 0.5)


@rpc("call_local", "reliable")
func jump():
	velocity.y = -jump_speed
	Debug.dprint("Chaser")


func setup(player_data: Game.PlayerData):
	set_multiplayer_authority(player_data.id)
	name = str(player_data.id)
	Debug.dprint(player_data.name, 30)
	Debug.dprint(player_data.role, 30)
	
	if multiplayer.get_unique_id() == player_data.id:
		camera_2d.enabled = true


@rpc
func test():
#	if is_multiplayer_authority():
	Debug.dprint("test - player: %s" % name, 30)
