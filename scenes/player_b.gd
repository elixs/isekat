extends Player


var was_on_floor = false
@onready var shake_area = $ShakeArea


func _ready():
	super._ready()
	animation_tree.set("parameters/TimeScale/scale", 0.75)


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


func _physics_process(delta):
	super._physics_process(delta)
	if is_on_floor() and not was_on_floor:
		_shake()
	was_on_floor = is_on_floor()


func _shake() -> void:
	camera_2d.shake()
	for body in shake_area.get_overlapping_bodies():
		var player = body as Player
		if player and player != self:
			if player.is_on_floor():
				player.camera_2d.shake((1 - global_position.distance_to(body.global_position) / 128)*5)
