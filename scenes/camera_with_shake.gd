class_name CameraWithShake
extends Camera2D

@export var strength = 5
@export var steps = 5
@export var step_duration = 0.025


func shake(new_stregth = 0):
	var current_strength = strength
	if(new_stregth):
		current_strength = new_stregth
	var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
	for i in steps:
		tween.tween_property(self, "offset", _get_rand_vector() * current_strength, step_duration)
	tween.tween_property(self, "offset", Vector2.ZERO, step_duration )


func _get_rand_vector() -> Vector2:
	return Vector2(randf(), randf())
