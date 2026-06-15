extends Node

var light: bool = false

signal light_changed(light)

func _ready() -> void:
	#emit_signal("light_changed", light)
	pass

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("light_toggle"):
		light = !light
		emit_signal("light_changed", light)
