extends Node2D

@export var serving_plate:Node
@onready var queue_layer: CanvasLayer = %QueueLayer



func _on_tap_component_item_tapped() -> void:
	serving_plate.item_list.clear()
	# Also clear the receiver component in queue layer
	if queue_layer and serving_plate:
		serving_plate.item_list.clear()
	print("Discarded all items from both serving plate and receiver component")
