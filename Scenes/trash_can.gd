extends Node2D

@export var serving_plate:Node



func _on_tap_component_item_tapped() -> void:
	serving_plate.item_list.clear()
