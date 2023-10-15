class_name ChaserPlayer
extends CharacterBody2D

signal off_the_hook
signal swinging_pos(pos)

@onready var collision_shape = $CollisionShape2D
@onready var animation_player = $AnimationPlayer
@onready var attack_collision = $Pivot/AttackArea/AttackCollision



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
var hooked : bool = false
var hooked_pos : Vector2
var colliding_with : int = 1

func _physics_process(delta: float) -> void:

	if hooked:
		swinging_pos.emit(global_position)
	
	if not is_on_floor() and not hooked:
		velocity.y += get_gravity() * delta
	else:
		is_flying = false;
	
	if is_multiplayer_authority():
		var move_input = Input.get_axis("move_left", "move_right")
		
		if Input.is_action_pressed("attack"):
			animation_player.play("attack")
			attack_collision.disabled = false
		
		if Input.is_action_pressed("jump") and not hooked:
			#jump.rpc() jump unabled for the moment
#			jump()
			velocity.y = move_toward(velocity.y, -max_fly_up_speed, fly_acceleration_up * delta)
			is_flying = true;
		
		if is_flying and not hooked:
			velocity.x = move_toward(velocity.x, max_fly_side_speed * move_input, fly_acceleration_side * delta)
		elif hooked:
			velocity = (hooked_pos - global_position).normalized() * Vector2(150, 150)
		else:
			velocity.x = move_toward(velocity.x, max_speed * move_input, acceleration * delta)
		
		send_info.rpc(global_position, velocity)
	
	if colliding_with < get_slide_collision_count():
		hooked = false
		off_the_hook.emit()
	
	colliding_with = get_slide_collision_count()
	for index in range(colliding_with):
			var collision = get_slide_collision(index)
			var collider = collision.get_collider()
			if (collider != null):
				if collider.is_in_group("destroyable"):
					collider.queue_free()
				elif collider.is_in_group("portal"):
					collider.teleport(self)
						
				
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


func setup(player_data: Game.PlayerData):
	set_multiplayer_authority(player_data.id)
	name = str(player_data.id)
	
	if multiplayer.get_unique_id() == player_data.id:
		camera_2d.enabled = true

@rpc
func test():
#	if is_multiplayer_authority():
	Debug.dprint("test - player: %s" % name, 30)


func _on_hook_hooked(hooked_position):
	hooked_pos = hooked_position
	hooked = true
	# await get_tree().create_timer(0.2).timeout


func _on_animation_player_animation_finished(anim_name):
	animation_player.play("idle")
	attack_collision.disabled = true
