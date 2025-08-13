extends Node

@onready var serving_plate: Node = $".."
@onready var food_visual: Node = $"../FoodVisual"

var child_name_to_item_name: Dictionary = {
	"Nasi": "Nasi",
	"AyamPop": "Ayam Pop",
	"Rendang": "Rendang",
	"Telur": "Telur",
	"Sayur": "Sayur",
	"Sambal": "Sambal",
	"EsTeh": "Es Teh",
}

var _previous_items: PackedStringArray = []


func _ready() -> void:
	_hide_all_food_visuals()
	if is_instance_valid(serving_plate):
		serving_plate.item_received.connect(_on_items_changed)
		serving_plate.item_send.connect(_on_items_changed)
	_on_items_changed()
	set_process(true)


func _process(_delta: float) -> void:
	var current: PackedStringArray = []
	if is_instance_valid(serving_plate):
		current = serving_plate.item_list
	if current != _previous_items:
		_previous_items = current.duplicate()
		_update_food_visuals()


func _on_items_changed() -> void:
	_update_food_visuals()


func _hide_all_food_visuals() -> void:
	if not is_instance_valid(food_visual):
		return
	for child in food_visual.get_children():
		if child is CanvasItem:
			child.hide()


func _update_food_visuals() -> void:
	if not is_instance_valid(food_visual) or not is_instance_valid(serving_plate):
		return
	var items: PackedStringArray = serving_plate.item_list
	for child in food_visual.get_children():
		if child is CanvasItem:
			var child_name: String = str(child.name)
			var item_name: String = child_name_to_item_name.get(child_name, child_name)
			child.visible = items.has(item_name)
