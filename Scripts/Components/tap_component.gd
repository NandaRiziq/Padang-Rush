extends Area2D

@onready var bounce_component: Node = $"../BounceComponent"
signal item_tapped


func _input_event(viewport: Viewport, event: InputEvent, shape_idx: int) -> void:
	if event.is_action_pressed("tap"):
		bounce_component.bounce()
		item_tapped.emit()
		print('item tapped')
