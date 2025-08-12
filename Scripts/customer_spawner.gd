extends Node2D

@onready var queue_layer: CanvasLayer = %QueueLayer
@onready var timer: Timer = $Timer

var customer_scene: PackedScene = preload("res://Scenes/customer.tscn")
@onready var off_queue_layer: CanvasLayer = $'../OffQueueLayer'

func _ready() -> void:
    # timer settings
    timer.timeout.connect(spawn_customer)
    timer.wait_time = Global.spawn_delay
    timer.start()

    # stop spawning when game over
    Global.game_over.connect(_on_game_over)

    #spawn first customer
    await get_tree().create_timer(2.0).timeout
    spawn_customer()


func _process(_delta: float) -> void:
    pass


func spawn_customer() -> void:
    # if there is slot available, spawn a customer
    if queue_layer.taken_slot.size() < Global.allowed_customers:
        var new_customer = customer_scene.instantiate()
        new_customer.queue_layer = queue_layer
        self.reparent(off_queue_layer, true)
        add_child(new_customer)


func _on_game_over() -> void:
    if is_instance_valid(timer):
        timer.stop()