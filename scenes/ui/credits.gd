extends CanvasLayer

@onready var rich_text_label = $MarginContainer/RichTextLabel
@onready var scroll_bar: VScrollBar = rich_text_label.get_v_scroll_bar()
@onready var player: Player = $Player as Player
@onready var camera_with_shake = $CameraWithShake

func _ready():
	scroll_bar.step = 0.01
	set_process(false)
	await get_tree().create_timer(3).timeout
	set_process(true)
	player.stomp.connect(func(): camera_with_shake.shake())



func _process(delta):
	scroll_bar.value += 0.1
