extends Node2D

var initial_pos:Vector2
var origin_pos:Vector2
var offset_pos:int = 50
var swipe_duration:float = 0.3
var order_duration:float = 0.5

@onready var order_label: Label = $PanelContainer/MarginContainer/OrderLabel
@onready var customer: Node2D = $".."


func _ready() -> void:
	customer.order_ready.connect(show_order_label)
	
	order_label.text = ""
	self.modulate.a = 0 #transparent
	origin_pos = self.position
	initial_pos = self.position - Vector2(offset_pos, 0)
	self.position = initial_pos


### swipe in animation
func swipe_in_order() -> void:
	var swipe_in = create_tween()
	swipe_in.tween_property(self, "position", origin_pos, swipe_duration)
	swipe_in.set_parallel()
	swipe_in.tween_property(self, "modulate:a", 1, swipe_duration)
	await swipe_in.finished
	
	#var type_order = create_tween()
	#type_order.tween_property(order_label, "visible_ratio", 1, order_duration)


### set order label text according to order list
func show_order_label() -> void:
	print(customer.order)
	for item in customer.order:
		if item != customer.order[len(customer.order)-1]:
			order_label.text += item + '\n'
		else:
			order_label.text += item
	order_label.visible_ratio = 1 #hide text
	swipe_in_order()
