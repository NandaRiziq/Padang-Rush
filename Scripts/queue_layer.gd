extends CanvasLayer

@onready var queue_pos_1: Marker2D = $QueuePos1
@onready var queue_pos_2: Marker2D = $QueuePos2
@onready var queue_pos_3: Marker2D = $QueuePos3
@onready var queue_pos_4: Marker2D = $QueuePos4

var available_slot: Array
signal queue_slot_ready


func _ready() -> void:
	available_slot = [
	queue_pos_1,
	queue_pos_2,
	queue_pos_3,
	queue_pos_4
	]
	queue_slot_ready.emit()
	#print('\navailable slot:', len(available_slot))


func restore_slot(slot) -> void:
	available_slot.append(slot)
