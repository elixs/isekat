extends Player


func skill():
	if state == Player.State.NORMAL:
		state = Player.State.SKILL
	else:
		state = Player.State.NORMAL
	Debug.dprint("Player B Skill")

func state_skill(delta: float) -> void:
	if is_multiplayer_authority():
		var move_input = Input.get_vector("move_left", "move_right", "move_up", "move_down")
		velocity = velocity.move_toward(max_speed * move_input, acceleration * delta)
		
		if Input.is_action_just_pressed("skill"):
			set_state(Player.State.NORMAL)
		send_info.rpc(global_position, velocity)
	move_and_slide()
