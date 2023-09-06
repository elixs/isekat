class_name ChaserPlayer
extends CharacterBody2D

# WALKING #
@export var max_speed : float = 200
@export var acceleration : float = 5000

@onready var camera_2d: Camera2D = $Camera2D
@onready var pivot: Node2D = $Pivot

# Flying
@export var max_fly_up_speed : float = 240
@export var max_fly_side_speed : float = 1000
@export var fly_gravity : float = 250
@export var fly_acceleration_up : float = 350
@export var fly_acceleration_side: float = 100

# JUMP # 
@export var jump_height : float 
@export var jump_time_to_peak: float
@export var jump_time_to_descent : float

@onready var jump_velocity : float = ((2.0 * jump_height) / jump_time_to_peak) * -1
@onready var jump_gravity : float = ((-2.0 * jump_height) / pow(jump_time_to_peak, 2)) * -1
@onready var fall_gravity : float = ((-2.0 * jump_height) / pow(jump_time_to_descent, 2)) * -1

var is_flying : bool = false

func _physics_process(delta: float) -> void:
	
	if not is_on_floor():
		velocity.y += get_gravity() * delta
	else:
		is_flying = false;
	
	if is_multiplayer_authority():
		var move_input = Input.get_axis("move_left", "move_right")
		
		if Input.is_action_pressed("jump"):
			#jump.rpc() jump unabled for the moment
#			jump()

			velocity.y = move_toward(velocity.y, -max_fly_up_speed, fly_acceleration_up * delta)
			is_flying = true;
		
		if is_flying:
			velocity.x = move_toward(velocity.x, max_fly_side_speed * move_input, fly_acceleration_side * delta)
		else:
			velocity.x = move_toward(velocity.x, max_speed * move_input, acceleration * delta)
		
		send_info.rpc(global_position, velocity)
#	else:
#		pass

	move_and_slide()

	if velocity.x != 0:
		pivot.scale.x = sign(velocity.x)

func get_gravity() -> float:
	if is_flying: return fly_gravity
	return jump_gravity if velocity.y < 0.0 else fall_gravity

@rpc("unreliable_ordered")
func send_info(pos: Vector2, vel: Vector2) -> void:
	global_position = lerp(global_position, pos, 0.5)
	velocity = lerp(velocity, vel, 0.5)


@rpc("call_local", "reliable")
func jump():
	velocity.y = jump_velocity
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
