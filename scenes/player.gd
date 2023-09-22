class_name Player
extends CharacterBody2D

enum State {
	NORMAL,
	SKILL
}

var state: State = State.NORMAL:
	set = set_state
		

var max_speed = 200
var jump_speed = 200
var acceleration = 1000
var gravity = 400
var normal_gravity = 400

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var playback: AnimationNodeStateMachinePlayback = animation_tree.get("parameters/playback")
@onready var pivot: Node2D = $Pivot
@onready var camera_2d: Camera2D = $Camera2D

@onready var bullet_spawner: MultiplayerSpawner = $BulletSpawner

@export var max_jumps = 2
var jumps = 0

func _ready() -> void:
	animation_tree.active = true
#	set_multiplayer_authority(name.to_int())


func _physics_process(delta: float) -> void:
	
	match state:
		State.NORMAL:
			state_normal(delta)
		State.SKILL:
			state_skill(delta)


func state_normal(delta: float) -> void:
	
#	Debug.dprint(velocity)
	
	if not is_on_floor():
		velocity.y += gravity * delta
	
	if is_multiplayer_authority():
		var move_input = Input.get_axis("move_left", "move_right")
		
		if is_on_floor() and jumps != 0:
			jumps = 0
		
		if jumps < max_jumps and Input.is_action_just_pressed("jump"):
			jumps += 1
			jump.rpc()
#			jump()
		
		if Input.is_action_just_pressed("skill"):
			skill.rpc()
	
		velocity.x = move_toward(velocity.x, max_speed * move_input, acceleration * delta)
		
		send_info.rpc(global_position, velocity)
		
		
		if Input.is_action_just_pressed("fire"):
			bullet_spawner.fire()
#	else:
#		pass

	move_and_slide()
	
	
	# animation
	
	if velocity.x != 0:
		pivot.scale.x = sign(velocity.x)
	
	if is_on_floor():
		if abs(velocity.x) > 0:
			playback.travel("run")
		else:
			playback.travel("idle")
	else:
		if velocity.y < 0:
			playback.travel("jump")
		else:
			playback.travel("fall")


func state_skill(delta: float) -> void:
	pass


func _input(event: InputEvent) -> void:
	if is_multiplayer_authority():
		if event.is_action_pressed("test"):
			test.rpc_id(1)


@rpc("unreliable_ordered")
func send_info(pos: Vector2, vel: Vector2) -> void:
	global_position = lerp(global_position, pos, 0.5)
	velocity = lerp(velocity, vel, 0.5)


@rpc("call_local", "reliable")
func jump():
	velocity.y = -jump_speed


func setup(player_data: Game.PlayerData):
	
	set_multiplayer_authority(player_data.id, false)
	name = str(player_data.id)
	Debug.dprint(player_data.name, 30)
	Debug.dprint(player_data.role, 30)
#	if player_data.role == Game.Role.ROLE_B:
#		modulate = Color.DARK_BLUE
	if multiplayer.get_unique_id() == player_data.id:
		camera_2d.enabled = true



@rpc
func test():
#	if is_multiplayer_authority():
	Debug.dprint("test - player: %s" % name, 30)

@rpc("call_local", "reliable")
func skill():
	Debug.dprint("Player Skill")


func set_state(value):
	state = value
