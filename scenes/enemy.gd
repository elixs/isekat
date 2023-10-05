extends CharacterBody2D

var max_speed = 50
var acceleration = 1000
var gravity = 400
var jump_speed = 200

@export var vel: Vector2 = Vector2.ZERO:
	set(value):
		vel = value
		if not is_multiplayer_authority():
			velocity = vel

@onready var pivot = $Pivot
@onready var floor_ray_cast = $Pivot/FloorRayCast
@onready var jump_timer = $JumpTimer


func _ready():
	if is_multiplayer_authority():
		jump_timer.timeout.connect(_jump)
		jump_timer.start()

func _physics_process(delta):
	var direction = pivot.scale.x
	
	if not is_on_floor():
		velocity.y += gravity * delta
	
	velocity.x = move_toward(velocity.x, direction * max_speed, acceleration * delta)
	
	if is_on_floor() and not floor_ray_cast.is_colliding():
		pivot.scale.x *= -1
	
	move_and_slide()
	
	if is_multiplayer_authority():
		vel = velocity


func _jump():
	velocity.y -= jump_speed
	vel = velocity
	jump_timer.start(randf_range(2, 4))
