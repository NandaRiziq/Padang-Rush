extends Control

@onready var start_button: Button = $Button


func _ready() -> void:
	start_button.pressed.connect(_on_start_button_pressed)


func _on_start_button_pressed() -> void:
	# Reset game state using Global singleton
	Global.reset_game_state()
	# Change to main game scene
	get_tree().change_scene_to_file("res://main.tscn")
