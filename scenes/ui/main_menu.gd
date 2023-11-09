extends MarginContainer

@onready var start = %Start
@onready var settings = %Settings
@onready var credits = %Credits
@onready var quit = %Quit


func _ready():
	if Game.multiplayer_test:
		get_tree().change_scene_to_file("res://scenes/lobby_test.tscn")
		return
	start.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/lobby.tscn"))
	settings.pressed.connect(func(): Debug.dprint("TODO make settings"))
	credits.pressed.connect(func(): Debug.dprint("TODO make credits"))
	quit.pressed.connect(func(): get_tree().quit())
	
