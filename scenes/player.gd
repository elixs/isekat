class_name Player
extends CharacterBody2D

var max_speed = 200
var jump_speed = 200
var acceleration = 1000
var gravity = 400


func _physics_process(delta: float) -> void:
	if is_multiplayer_authority():
		var move_input = Input.get_axis("move_left", "move_right")
		if not is_on_floor():
			velocity.y += gravity * delta
		
		if Input.is_action_just_pressed("jump"):
			velocity.y = -jump_speed
	
		velocity.x = move_toward(velocity.x, max_speed * move_input, acceleration * delta)
		move_and_slide()
		send_info.rpc(global_position)
#	else:
#		pass


func _input(event: InputEvent) -> void:
	if is_multiplayer_authority():
		if event.is_action_pressed("test"):
			test.rpc_id(1)


@rpc("unreliable_ordered")
func send_info(pos: Vector2) -> void:
	global_position = pos

func setup(player_data: Game.PlayerData):
	set_multiplayer_authority(player_data.id)
	name = str(player_data.id)
	Debug.dprint(player_data.name, 30)
	Debug.dprint(player_data.role, 30)



@rpc
func test():
#	if is_multiplayer_authority():
	Debug.dprint("test - player: %s" % name, 30)
