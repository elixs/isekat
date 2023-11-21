extends CharacterBody2D

var max_speed = 50
var acceleration = 1000
var gravity = 400
var jump_speed = 200

var direction = 0

@export var vel: Vector2 = Vector2.ZERO:
	set(value):
		vel = value
		if not is_multiplayer_authority():
			velocity = vel

@onready var pivot = $Pivot
@onready var floor_ray_cast = $Pivot/FloorRayCast
@onready var action_timer = $ActionTimer
@onready var detection_area = $DetectionArea

var player: Player

func _ready():
	if is_multiplayer_authority():
		action_timer.timeout.connect(_action)
		detection_area.body_entered.connect(_on_body_entered)
		detection_area.body_exited.connect(_on_body_exited)

func _physics_process(delta):
	
	if not is_on_floor():
		velocity.y += gravity * delta


	
	velocity.x = move_toward(velocity.x, direction * max_speed, acceleration * delta)

	if is_on_floor() and not floor_ray_cast.is_colliding():
		direction *= -1
		velocity.x *= -1
	
	if is_multiplayer_authority():
		if player and is_on_floor():
			check_jump()

	
	if velocity.x != 0:
		pivot.scale.x = sign(velocity.x)
	
	move_and_slide()
	
	if is_multiplayer_authority():
		vel = velocity



func _action():
	if randi() % 4:
		direction = 0
	else:
		# move
		if randi() % 2:
			direction = 1
		else:
			direction = -1
	action_timer.start(randf_range(1, 2))

func _jump():
	velocity.y = -jump_speed
	vel = velocity
#	jump_timer.start(randf_range(2, 4))


func _on_body_entered(body: Node):
	player = body

func _on_body_exited(body: Node):
	player = null


func check_jump():
#	Debug.dprint("test")
	if sign(player.global_position.x - global_position.x) * sign(player.velocity.x) < 0 and sign(player.velocity.y) < 0:
		_jump()
		direction = -sign(player.velocity.x)
		velocity.x = -player.velocity.x
		
