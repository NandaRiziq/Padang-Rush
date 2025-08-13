extends Area2D

@onready var bounce_component: Node = $"../BounceComponent"
@onready var sfx_player: AudioStreamPlayer = $"../SFX"
signal item_tapped


func _input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if event.is_action_pressed("tap"):
		bounce_component.bounce()
		if is_instance_valid(sfx_player):
			sfx_player.play()
		item_tapped.emit()
		print('item tapped')
