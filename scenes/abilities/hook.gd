extends RayCast2D
@onready var line_2d = $Line2D

var end_point : Vector2 

signal hooked(hooked_position)

func _ready():
	line_2d.top_level = true
	line_2d.global_position = Vector2.ZERO



func _input(event):
	if event.is_action_pressed("hook"):
		check_collision()


func check_collision():
	look_at(get_global_mouse_position())
	var collision_point
	force_raycast_update()
	if is_colliding():
		if get_collider() is RunnerPlayer:
			return
		line_2d.clear_points()
		line_2d.add_point(global_position)
		collision_point = get_collision_point()
		line_2d.add_point(collision_point)
		end_point = collision_point
		hooked.emit(collision_point)
		



func _on_chaser_off_the_hook():
	line_2d.clear_points() # Replace with function body.


func _on_chaser_swinging_pos(pos):
	line_2d.set_point_position(0, pos)
