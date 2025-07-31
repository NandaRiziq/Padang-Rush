extends Marker2D

@onready var customer: Node2D = $"../../Customer"

var customer_order: Array


func _ready() -> void:
	customer.order_ready.connect(get_order_data.bind())


func get_order_data():
	customer_order = customer.order
