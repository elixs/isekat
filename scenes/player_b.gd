extends Player

var jetpack_acceleration = 500
var jetpack_max_speed = 50

var was_on_floor = false
@onready var shake_area = $ShakeArea

@onready var particles_left = $Pivot/JetpackLeft/ParticlesLeft
@onready var particles_right = $Pivot/JetpackRight/ParticlesRight

@onready var progress_bar = $Pivot/ProgressBar

var max_fuel = 100
@export var fuel = 100:
	set(value):
		fuel = value
		if progress_bar:
			progress_bar.value = fuel


func _ready():
	super._ready()
	animation_tree.set("parameters/TimeScale/scale", 0.75)

func skill():
	set_state(State.SKILL)
	particles_left.emitting = true
	particles_right.emitting = true
	fuel = max_fuel


func state_skill(delta):
	velocity.y += gravity * delta
	
	var move_input = 0
	
	if is_multiplayer_authority():
		move_input = Input.get_axis("move_left", "move_right")
		
		velocity.x = move_toward(velocity.x, max_speed * move_input, acceleration * delta)
		
		if Input.is_action_pressed("skill") and fuel > 0:
			fuel -= delta
			velocity.y = move_toward(velocity.y, -jetpack_max_speed, jetpack_acceleration * delta)
		else:
			set_state(State.NORMAL)
			particles_left.emitting = false
			particles_right.emitting = false
			return

		Debug.dprint(velocity.y)
		
		
		send_info.rpc(global_position, velocity)


		if velocity.y < 0:
			playback.travel("jump")
		else:
			playback.travel("fall")

	move_and_slide()
	
	
	# animation
	
	if velocity.x != 0:
		pivot.scale.x = sign(velocity.x)
	


func _physics_process(delta):
	super._physics_process(delta)
	if is_on_floor() and not was_on_floor:
		_shake()
	was_on_floor = is_on_floor()



func _shake() -> void:
	stomp.emit()
	camera_2d.shake()
	for body in shake_area.get_overlapping_bodies():
		var player = body as Player
		if player and player != self:
			if player.is_on_floor():
				player.camera_2d.shake((1 - global_position.distance_to(body.global_position) / 128)*5)
