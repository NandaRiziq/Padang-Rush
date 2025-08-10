extends Node2D

@onready var tap_component: Area2D = $TapComponent
@onready var bounce_component: Node = $BounceComponent

@export var receiver:Node #empty if only receiving
@export_enum("Nasi", "Ayam Pop", "Rendang", "Telur", "Sayur", "Sambal", "Es Teh")
var item_list:PackedStringArray = []

signal item_received
signal item_send


func _ready() -> void:
	if is_instance_valid(tap_component):
		tap_component.item_tapped.connect(send_item)


func send_item():
	if receiver:
		for item in item_list:
			receiver.receive_item(item)
			print('Sent:', item)
	item_send.emit()


func receive_item(item:String):
	if item in item_list:
		if is_instance_valid(bounce_component):
			bounce_component.bounce()
	else:
		item_list.append(item)
		item_received.emit()
	print('Received:', item)
	print(item_list,'\n')
