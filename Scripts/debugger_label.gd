extends Label

@onready var queue_layer: CanvasLayer = %QueueLayer
@onready var timer: Timer = $'../../OffQueueLayer/CustomerSpawner/Timer'

func _process(_delta: float) -> void:
    text = """
    difficulty: %d                      available slot: %d
    max customers: %d           customer spawn delay: %d
    max main dish: %d
    taken slot: %d
    """ % [
    Global.game_difficulty,
    queue_layer.available_slot.size(),
    Global.allowed_customers,
    Global.spawn_delay,
    Global.allowed_main_dish,
    queue_layer.taken_slot.size(),
]