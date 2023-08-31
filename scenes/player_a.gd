extends Player

func skill():
	super.skill()
	Debug.dprint("Player A Skill")
	global_position = get_global_mouse_position()
