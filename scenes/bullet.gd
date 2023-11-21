extends Area2D

@export var speed = 300

#@onready var gpu_particles_2d = $GPUParticles2D

func _ready() -> void:
	if multiplayer.is_server():
		body_entered.connect(_on_body_entered)
	
#	await get_tree().create_timer(2 * gpu_particles_2d.lifetime)
#	queue_free()

func _physics_process(delta: float) -> void:
	position += transform.x * speed * delta

func _on_body_entered(body: Node2D) -> void:
	pass
	# Debug.dprint(body.name)
