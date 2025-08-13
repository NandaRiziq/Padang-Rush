extends Node2D

@export var serving_plate:Node
@onready var queue_layer: CanvasLayer = %QueueLayer
@onready var sfx_player: AudioStreamPlayer = $SFX

const DISCARD_COST: int = 25


func _on_tap_component_item_tapped() -> void:
	# Require items to be present; if empty, do nothing
	if not is_instance_valid(serving_plate):
		return
	var items: PackedStringArray = serving_plate.item_list
	if items.size() == 0:
		print("Trash can tapped, but serving plate is empty. No coins deducted.")
		return

	# Deduct coins if possible, but always clear items
	if Global.player_money >= DISCARD_COST:
		Global.add_money(-DISCARD_COST)
		print("Discarded items. Deducted ", DISCARD_COST, " coins.")
	else:
		print("Discarded items. Not enough coins to deduct.")
	serving_plate.item_list.clear()
	_play_trash_sfx()


func _play_trash_sfx() -> void:
	if not is_instance_valid(sfx_player):
		return
	var stream: AudioStream = load("res://Assets/Sounds/garbage pile hit 1.wav")
	if stream:
		sfx_player.stream = stream
		sfx_player.play()
