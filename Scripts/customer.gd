extends Node2D

@onready var customer_sprite: Sprite2D = $CustomerSprite
@onready var order_label: Node2D = $OrderLabel
@onready var patience_bar: ProgressBar = $OrderLabel/PatienceBar

@export var menu: menu_resource = menu_resource.new()
var order: Array
var order_ready: bool = false
var choosen_char

### char sprites
var char: Array = [
	[ #char 1
	"res://Assets/Character/Char1.png",
	"res://Assets/Character/Char1-smiling.png"
	],
	[ #char 2
	"res://Assets/Character/Char2.png",
	"res://Assets/Character/Char2-smiling.png"
	],
]


func _ready() -> void:
	# delete customer upon patience depleted
	patience_bar.patience_depleted.connect(func free_customer() -> void:
		self.queue_free())
	
	# select random character and set the texture appropriately
	random_char()
	customer_sprite.texture = load(choosen_char[0])
	
	# randomize order
	random_order()
	
	# set order label according to order list
	order_label.show_order_label()


func random_char() -> void:
	choosen_char = char[randi_range(0, len(char)-1)]


func random_order():
	# 30% chance just drink order
	var just_drink = false
	if randf() < 0.3:
		just_drink = true
		order.append("es teh")
		return
	
	# always add nasi if it's normal order
	order.append("nasi")
	
	# 70% chance include main dish
	if randf() < 0.7:
		var dish_chosen = false
		while not dish_chosen:
			var chosen_main_dish: String = menu.main_dish[randi_range(0, len(menu.main_dish)-1)]
			if chosen_main_dish not in order:
				order.append(chosen_main_dish)
				dish_chosen = true
	
	# 60% chance include sayur
	if randf() < 0.6:
		order.append("sayur")
	
	# 60% chance include sambal
	if randf() < 0.6:
		order.append("sambal")
	
	# 50% chance include sayur
	if randf() < 0.5:
		order.append("es teh")
	print('\n\n\n', order)
	
