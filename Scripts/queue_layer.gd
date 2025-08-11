extends CanvasLayer

@onready var queue_pos_1: Marker2D = $QueuePos1
@onready var queue_pos_2: Marker2D = $QueuePos2
@onready var queue_pos_3: Marker2D = $QueuePos3
@onready var queue_pos_4: Marker2D = $QueuePos4
@onready var serving_plate: Node2D = $"../TableLayer/ServingPlate"

var available_slot: Array
var taken_slot: Array
var served_items: Array

signal queue_slot_ready


func _ready() -> void:
	# Only check orders once the serving plate sends the full assembled order
	serving_plate.item_send.connect(check_order)
	available_slot = [
	queue_pos_1,
	queue_pos_2,
	queue_pos_3,
	queue_pos_4
	]
	call_deferred("emit_signal", "queue_slot_ready")


func use_slot(slot) -> void:
	taken_slot.append(slot)
	available_slot.erase(slot)


func restore_slot(slot) -> void:
	available_slot.append(slot)
	taken_slot.erase(slot)
	

func check_order() -> void:
	# Use the assembled items on the serving plate as the definitive order
	var received_order: Array = serving_plate.item_list
	if received_order.is_empty():
		print('received order is empty')
		return
	
	print('received order is:', received_order)
	
	# find customer node in queue slot
	for slot in taken_slot:
		var customer: Customer
		for child in slot.get_children():
			if child is Customer:
				customer = child
				break
	
		if customer:
			if order_match(received_order, customer.order):
				print('order match!')
				# award coins for successful order
				Global.add_money(100)
				customer.walk_out_queue(true)
				serving_plate.item_list.clear()
				return  # Exit the function after finding a match


func order_match(order1: Array, order2: Array) -> bool:
	if order1.size() != order2.size():
		return false
	
	# check if order exactly match
	var sorted1 = order1.duplicate()
	var sorted2 = order2.duplicate()
	sorted1.sort()
	sorted2.sort()
	
	return sorted1 == sorted2
