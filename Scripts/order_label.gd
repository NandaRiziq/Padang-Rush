extends Node2D

var initial_pos:Vector2
var origin_pos:Vector2
var offset_pos:int = 50
var swipe_duration:float = 0.5
var order_duration:float = 0.5

@onready var label: Label = $PanelContainer/MarginContainer/Label


func _ready() -> void:
	self.modulate.a = 0 #transparent
	origin_pos = self.position
	initial_pos = self.position - Vector2(offset_pos, 0)
	self.position = initial_pos
	
	label.visible_ratio = 1 #hide text
	
	#swipe in animation
	var swipe_in = create_tween()
	swipe_in.tween_property(self, "position", origin_pos, swipe_duration)
	swipe_in.set_parallel()
	swipe_in.tween_property(self, "modulate:a", 1, swipe_duration)
	await swipe_in.finished
	
	#var type_order = create_tween()
	#type_order.tween_property(label, "visible_ratio", 1, order_duration)
