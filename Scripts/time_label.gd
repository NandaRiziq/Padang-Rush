extends Label

@onready var main: Node2D = get_node("/root/Main")

func _ready() -> void:
	if main:
		main.second_passed.connect(update_time)
	else:
		push_error("Main node not found!")

func update_time() -> void:
	if main:
		text = main.current_time
