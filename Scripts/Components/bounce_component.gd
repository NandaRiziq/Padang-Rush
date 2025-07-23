extends Node

@export var tween_duration:float = 0.1
@export var target_scale_multiplier: float = 1.25
@onready var parent = get_parent()
var origin_scale: Vector2 
var target_scale: Vector2


func _ready() -> void:
	origin_scale = parent.scale
	target_scale = origin_scale * target_scale_multiplier


func bounce() -> void:
	var tween = create_tween()
	tween.tween_property(parent, "scale", target_scale, tween_duration)
	tween.tween_property(parent, "scale", origin_scale, tween_duration)
