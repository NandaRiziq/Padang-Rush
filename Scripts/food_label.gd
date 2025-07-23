extends Label

@onready var serving_plate: Node2D = $".."


func _process(delta: float) -> void:
	self.text = str(serving_plate.item_list)
