class_name Customer
extends Node2D

@onready var customer_sprite: Sprite2D = $CustomerSprite
@onready var order_label: Node2D = $OrderLabel
@onready var patience_bar: ProgressBar = $OrderLabel/PatienceBar
@onready var customer_animation: AnimationPlayer = $CustomerAnimation
@onready var off_queue_layer: CanvasLayer = get_node("/root/Main/OffQueueLayer")
@onready var walk_out_layer: CanvasLayer = get_node("/root/Main/WalkOutLayer")

@export var walk_duration: float = 1.0
@export var walk_speed: float = 400.0
var menu: menu_resource = menu_resource.new()
var order: Array
var choosen_char
var chosen_queue_slot
var start_end_pos: Vector2
var queue_layer: CanvasLayer
var queue_ypos = 634.0

signal order_ready

### char sprites
var characters: Array = [
	[ #char 1
	"res://Assets/Character/Char1.png",
	"res://Assets/Character/Char1-smiling.png",
	"res://Assets/Character/Char1-angry.png"
	],
	[ #char 2
	"res://Assets/Character/Char2.png",
	"res://Assets/Character/Char2-smiling.png",
	"res://Assets/Character/Char2-angry.png"
	],
]


func _ready() -> void:
	#wait for the queue slot ready
	if queue_layer == null:
		await get_tree().process_frame
		queue_layer = get_tree().get_first_node_in_group("queue_layer")
	if queue_layer and queue_layer.available_slot.is_empty():
		await queue_layer.queue_slot_ready
	
	# customer walkout upon patience depleted
	patience_bar.patience_depleted.connect(walk_out_queue.bind(false))
	
	# choose start position
	choose_start_end_pos()
	self.position = start_end_pos
	
	# choose queue position
	choose_queue_slot()
	
	# select random character and set the texture appropriately
	random_char()
	customer_sprite.texture = load(choosen_char[0])
	
	# randomize order
	random_order()
	
	# walk animation
	walk_to_queue()


func random_char() -> void:
	choosen_char = characters[randi_range(0, len(characters)-1)]


func random_order():
	# 30% chance just drink order
	if randf() < 0.3:
		order.append("Es Teh")
		return
	
	# always add nasi if it's normal order
	order.append("Nasi")
	
	# 70% chance include main dish
	var main_dish_amount = randi_range(1, Global.allowed_main_dish)
	if randf() <= 0.7:
		for dish in range(main_dish_amount):
			var dish_chosen = false
			while not dish_chosen:
				var chosen_main_dish: String = menu.main_dish[randi_range(0, len(menu.main_dish)-1)]
				if chosen_main_dish not in order:
					order.append(chosen_main_dish)
					dish_chosen = true
	
	# 60% chance include sayur
	if randf() <= 0.6:
		order.append("Sayur")
	
	# 60% chance include sambal
	if randf() <= 0.6:
		order.append("Sambal")
	
	# 50% chance include sayur
	if randf() <= 0.5:
		order.append("Es Teh")


### choose random start position (left or right)
func  choose_start_end_pos() -> void:
	var window_size = get_viewport_rect().size
	if randf() <= 0.5:
		start_end_pos = Vector2(-200, queue_ypos)
	else:
		start_end_pos = Vector2(window_size.x + 200, queue_ypos)


func walk_to(target_pos: Vector2) -> void:
	customer_animation.walk_anim()
	var distance: float = self.global_position.distance_to(target_pos)
	var duration: float = max(0.05, distance / walk_speed)
	var walk_in = create_tween()
	walk_in.tween_property(self, "global_position", target_pos, duration)
	await walk_in.finished


### customer walking into queue

func walk_to_queue() -> void:
	await walk_to(chosen_queue_slot.global_position)
	self.reparent(chosen_queue_slot, true)
	customer_animation.idle_anim()
	order_ready.emit()


### customer walking out of queue to off screen

func walk_out_queue(is_succeed: bool):
	queue_layer.restore_slot(chosen_queue_slot)
	self.reparent(walk_out_layer, true)
	if is_succeed: # order fulfilled
		customer_sprite.texture = load(choosen_char[1]) # happy face
		order_label.hide()
		patience_bar.stop_patience_bar()
	else: # order failed
		customer_sprite.texture = load(choosen_char[2]) # angry face
		order_label.hide()
	choose_start_end_pos()
	await walk_to(start_end_pos)
	self.queue_free()


### choose random available queue slot
func choose_queue_slot() -> void:
	chosen_queue_slot = queue_layer.available_slot[randi_range(0, len(queue_layer.available_slot)-1)]
	queue_layer.use_slot(chosen_queue_slot)
