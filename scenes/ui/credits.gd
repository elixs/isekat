extends Node2D

@onready var player: Player = $Player as Player
@onready var camera_with_shake = $CameraWithShake
@onready var scrollable_text = $CanvasLayer/MarginContainer/ScrollableText
@onready var button = $CanvasLayer/Button


func _ready():
	button.hide()
	player.stomp.connect(func(): camera_with_shake.shake())
	scrollable_text.scroll_completed.connect(_on_scroll_completed)
	button.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn"))


func _on_scroll_completed():
	await get_tree().create_timer(3).timeout
	button.show()
	
