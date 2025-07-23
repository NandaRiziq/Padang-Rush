@tool
extends Sprite2D

@export var tween_duration:float = 0.1
@export var target_scale_multiplier: float = 1.25
@onready var parent = get_parent()
var origin_scale: Vector2 
var target_scale: Vector2


func _ready() -> void:
	origin_scale = self.scale
	target_scale = origin_scale * target_scale_multiplier


func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		if parent and parent.texture_list:
			self.texture = parent.[parent.texture_list]


func bounce() -> void:
	var tween = create_tween()
	tween.tween_property(self, "scale", target_scale, tween_duration)
	tween.tween_property(self, "scale", origin_scale, tween_duration)
	
