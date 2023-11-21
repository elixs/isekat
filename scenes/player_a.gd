extends Player

func _physics_process(delta):
	super._physics_process(delta)


func skill():
	super.skill()
	Debug.dprint("Player A Skill")
	global_position = get_global_mouse_position()
