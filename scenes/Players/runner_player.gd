class_name RunnerPlayer
extends CharacterBody2D

# WALKING #
@export var max_speed : float = 200
@export var acceleration : float = 1000

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
@export var grip_force : float # Reduction of gravity when sliding on walls

@onready var wall_jump_velocity_x : float = (2.0 * wall_jump_reach) / (wall_jump_time_to_peak)
@onready var wall_jump_velocity_y : float = ((2.0 * wall_jump_height) / wall_jump_time_to_peak) * -1
@onready var wall_jump_gravity : float = ((-2.0 * wall_jump_height) / pow(wall_jump_time_to_peak, 2)) * -1
@onready var horizontal_air_drag : float = (2.0 * wall_jump_reach) / wall_jump_time_to_peak

# COYOTE FRAMES #
@export var coyote_jump_frames : int # Frames that allow to perform a jump when in the air
@export var coyote_wall_jump_frames : int # Frames that allow to perform a wall jump when in the air

@onready var jump_window : int = coyote_jump_frames
@onready var wall_jump_window : int = coyote_wall_jump_frames

var wall_jumping : bool = false
var coyoted_wall_direction : WallSide = WallSide.DEFAULT # Store the last wall direction before leaving it

enum WallSide {
	LEFT = -1,
	RIGHT = 1,
	DEFAULT = 0,
}

func _physics_process(delta: float) -> void:
	
	velocity.y += get_gravity() * delta
	
	if is_multiplayer_authority():
		
		if is_on_floor(): 
			wall_jumping = false
			jump_window = coyote_jump_frames
			wall_jump_window = 0
			
		if is_on_wall_only():
			wall_jump_window = coyote_wall_jump_frames
			coyoted_wall_direction = get_which_wall_side_collided()
			jump_window = 0
			
		var move_input = Input.get_axis("move_left", "move_right")
		
		if Input.is_action_just_pressed("jump"):
			if wall_jump_window > 0: # Si se quiere poder saltar en cuanto se toca la muralla, se debería cambiar por is touching ony wall
				wall_jump(coyoted_wall_direction)
				wall_jumping = true
				wall_jump_window = 0
				
			elif jump_window > 0: 
				jump()
				jump_window = 0
		
		velocity.x = move_toward(velocity.x, max_speed * move_input, get_air_drag() * delta)
		send_info.rpc(global_position, velocity)
		
		wall_jump_window -= 1
		jump_window -= 1
	
	move_and_slide()
	
func get_gravity() -> float:
	if velocity.y > 0.0 :# drag shouldnt be affected by coyote
		return fall_gravity / grip_force
	elif velocity.y < 0.0:
		return wall_jump_gravity if wall_jumping else jump_gravity
	return fall_gravity
		
func get_air_drag() -> float:
	return acceleration if is_on_floor() else horizontal_air_drag

func is_gripping() -> bool:
	return is_on_wall_only()  and velocity.y > 0.0
	
func get_which_wall_side_collided() -> WallSide:
	
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		if collision.get_normal().x > 0:
			return WallSide.RIGHT
		elif collision.get_normal().x < 0:
			return WallSide.LEFT
	return WallSide.DEFAULT

func jump():
	velocity.y = jump_velocity
	Debug.dprint("Runner")
	
func wall_jump(side_multiplier):
	velocity.y = wall_jump_velocity_y
	velocity.x = wall_jump_velocity_x * side_multiplier

func setup(player_data: Game.PlayerData):
	set_multiplayer_authority(player_data.id)
	name = str(player_data.id)
	Debug.dprint(player_data.name, 30)
	Debug.dprint(player_data.role, 30)

@rpc("unreliable_ordered")
func send_info(pos: Vector2, vel: Vector2) -> void:
	global_position = lerp(global_position, pos, 0.5)
	velocity = lerp(velocity, vel, 0.5)
