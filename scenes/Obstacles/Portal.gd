extends StaticBody2D


@onready var direction_position = get_node("Direction").global_position

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func teleport(player):
	player.global_position = direction_position
	
