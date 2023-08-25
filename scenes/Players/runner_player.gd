class_name RunnerPlayer
extends CharacterBody2D

# WALKING #
@export var max_speed = 200
@export var acceleration = 1000

# JUMP # 
@export var jump_height : float
@export var jump_time_to_peak: float
@export var jump_time_to_descent : float

@onready var jump_velocity : float = ((2.0 * jump_height) / jump_time_to_peak) * -1
@onready var jump_gravity : float = ((-2.0 * jump_height) / pow(jump_time_to_peak, 2)) * -1
@onready var fall_gravity : float = ((-2.0 * jump_height) / pow(jump_time_to_descent, 2)) * -1

# WALL-JUMP #
@export var wall_jump_height : float
@export var wall_jump_reach : float # Distance before reaching the same height
@export var wall_jump_time_to_peak : float
@export var grip_force : float

@onready var wall_jump_velocity_x : float = (2.0 * wall_jump_reach) / (wall_jump_time_to_peak) # Not physically accurate but it works
@onready var wall_jump_velocity_y : float = ((2.0 * wall_jump_height) / wall_jump_time_to_peak) * -1
@onready var wall_jump_gravity : float = ((-2.0 * wall_jump_height) / pow(wall_jump_time_to_peak, 2)) * -1
@onready var horizontal_air_drag : float = (2.0 * wall_jump_reach) / wall_jump_time_to_peak

var wall_jumping : bool = false



func _physics_process(delta: float) -> void:
	
	velocity.y += get_gravity() * delta
	
	Debug.dprint(get_air_drag())
	
	if is_multiplayer_authority():
		if is_on_floor(): wall_jumping = false
		
		var move_input = Input.get_axis("move_left", "move_right")
		
		if Input.is_action_just_pressed("jump"):
			if is_gripping() and velocity.x == 0.0:
				wall_jump()
				wall_jumping = true
			elif is_on_floor(): 
				jump()
		
		velocity.x = move_toward(velocity.x, max_speed * move_input, get_air_drag() * delta)
		
		send_info.rpc(global_position, velocity)
	
	move_and_slide()
	
func get_gravity() -> float:
	if is_gripping():
		return fall_gravity / grip_force
	elif velocity.y < 0.0:
		return wall_jump_gravity if wall_jumping else jump_gravity
	return fall_gravity
		
func get_air_drag() -> float:
	return acceleration if is_on_floor() else horizontal_air_drag

func is_gripping() -> bool:
	return is_on_wall_only() and velocity.y > 0.0

@rpc("unreliable_ordered")
func send_info(pos: Vector2, vel: Vector2) -> void:
	global_position = lerp(global_position, pos, 0.5)
	velocity = lerp(velocity, vel, 0.5)


@rpc("call_local", "reliable")
func jump():
	velocity.y = jump_velocity
	Debug.dprint("Runner")
	
func wall_jump():
	velocity.y = wall_jump_velocity_y
	velocity.x = wall_jump_velocity_x


func setup(player_data: Game.PlayerData):
	set_multiplayer_authority(player_data.id)
	name = str(player_data.id)
	Debug.dprint(player_data.name, 30)
	Debug.dprint(player_data.role, 30)
