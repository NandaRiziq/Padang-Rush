extends Node2D

@onready var queue_layer: CanvasLayer = $"../QueueLayer"
@onready var customer_sprite: Sprite2D = $CustomerSprite
@onready var order_label: Node2D = $OrderLabel
@onready var patience_bar: ProgressBar = $OrderLabel/PatienceBar
@onready var customer_animation: AnimationPlayer = $CustomerAnimation

@export var walk_duration: float = 1.0
var menu: menu_resource = menu_resource.new()
var order: Array
var choosen_char
var chosen_queue_slot
var start_end_pos: Vector2

signal order_ready

### char sprites
var char: Array = [
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
	await queue_layer.queue_slot_ready
	
	# delete customer upon patience depleted
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
	choosen_char = char[randi_range(0, len(char)-1)]


func random_order():
	# 30% chance just drink order
	var just_drink = false
	if randf() < 0.3:
		just_drink = true
		order.append("Es Teh")
		return
	
	# always add nasi if it's normal order
	order.append("Nasi")
	
	# 70% chance include main dish
	if randf() <= 0.7:
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
func choose_start_end_pos() -> void:
	var window_size = get_viewport_rect().size
	if randf() <= 0.5:
		start_end_pos = Vector2(-200, self.position.y)
	else:
		start_end_pos = Vector2(window_size.x + 200, self.position.y)


func walk_to(target_pos) -> void:
	customer_animation.walk_anim()
	var walk_in = create_tween()
	walk_in.tween_property(self, "position", target_pos, walk_duration)
	await walk_in.finished


func walk_to_queue() -> void:
	await walk_to(chosen_queue_slot.position)
	customer_animation.idle_anim()
	order_ready.emit()


func walk_out_queue(is_succeed):
		queue_layer.restore_slot(chosen_queue_slot)
		if is_succeed:
			customer_sprite.texture = load(choosen_char[1])
		else:
			customer_sprite.texture = load(choosen_char[2])
		choose_start_end_pos()
		await walk_to(start_end_pos)
		self.queue_free()


func choose_queue_slot() -> void:
	chosen_queue_slot = queue_layer.available_slot[randi_range(0, len(queue_layer.available_slot)-1)]
	queue_layer.available_slot.erase(chosen_queue_slot)
