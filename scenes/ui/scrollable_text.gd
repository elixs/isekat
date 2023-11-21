extends RichTextLabel

@export var scroll_start = 3

@onready var scroll_bar: VScrollBar = get_v_scroll_bar()

signal scroll_completed

var _completed = false

var speed = 1

var _scroll_delta = 0

func _ready():
	scroll_bar.step = 0.01


func _process(delta):
	if Input.is_action_pressed("fire"):
		speed = 10
	else:
		speed = 1
	
	if _scroll_delta < scroll_start:
		_scroll_delta += delta * speed
	else:
		var old_scroll_value = scroll_bar.value
		scroll_bar.value += 0.1 * speed
		if !_completed and (scroll_bar.value == old_scroll_value):
			_completed = true
			scroll_completed.emit()
