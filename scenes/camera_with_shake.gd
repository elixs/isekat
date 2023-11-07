class_name CameraWithShake
extends Camera2D

@export var strength = 5
@export var steps = 10
@export var step_duration = 0.1


func shake():
	var tween = create_tween().set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	for i in steps:
		tween.tween_property(self, "offset", _get_rand_vector() * strength, step_duration)
	tween.tween_property(self, "offset", Vector2.ZERO, step_duration )


func _get_rand_vector() -> Vector2:
	return Vector2(randf(), randf())
