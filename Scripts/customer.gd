class_name Customer
extends Node2D

@onready var customer_sprite: Sprite2D = $CustomerSprite
@onready var order_label: Node2D = $OrderLabel
@onready var patience_bar: ProgressBar = $OrderLabel/PatienceBar
@onready var customer_animation: AnimationPlayer = $CustomerAnimation
@onready var off_queue_layer: CanvasLayer = get_node("/root/Main/OffQueueLayer")
@onready var walk_out_layer: CanvasLayer = get_node("/root/Main/WalkOutLayer")
@onready var sfx_patience: AudioStreamPlayer = $SFX_Patience

@export var walk_duration: float = 1.0
@export var walk_speed: float = 400.0
var menu: menu_resource = menu_resource.new()
var order: Array
var choosen_char
var chosen_queue_slot
var start_end_pos: Vector2
var queue_layer: CanvasLayer
var queue_ypos = 634.0
var has_switched_to_angry: bool = false

signal order_ready

### char sprites
var characters: Array = [
	[ #char Pria
	"res://Assets/Character/Pria-Senang.png",
	"res://Assets/Character/Pria-Senang.png",
	"res://Assets/Character/Pria-Marah.png",
	],
	[ #char Perempuan
	"res://Assets/Character/Perempuan-Senang.png",
	"res://Assets/Character/Perempuan-Senang.png",
	"res://Assets/Character/Perempuan-Marah.png",
	],
	[ #char Anak
	"res://Assets/Character/Anak-Kecil-Senang.png",
	"res://Assets/Character/Anak-Kecil-Senang.png",
	"res://Assets/Character/Anak-Kecil-Marah.png",
	],
	[ #char Kakek
	"res://Assets/Character/Kakek-Senang.png",
	"res://Assets/Character/Kakek-Senang.png",
	"res://Assets/Character/Kakek-Marah.png",
	]
]

### particle asset
var particle_textures: Array[Texture2D] = [
	preload("res://Assets/Object/Coin-50x50.png"),
	preload("res://Assets/Object/angry-emoji-50x50.png")
]

@onready var particles: GPUParticles2D = $GPUParticles2D


func _ready() -> void:
	#wait for the queue slot ready
	# Pre-warm particle system next frame to avoid first-use stutter
	call_deferred("_prewarm_particles")
	if queue_layer == null:
		await get_tree().process_frame
		queue_layer = get_tree().get_first_node_in_group("queue_layer")
	if queue_layer and queue_layer.available_slot.is_empty():
		await queue_layer.queue_slot_ready
	
	# customer walkout upon patience depleted
	patience_bar.patience_depleted.connect(_on_patience_depleted)
	# react to patience changes for face updates
	if is_instance_valid(patience_bar):
		patience_bar.value_changed.connect(_on_patience_value_changed)
	
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


func _on_patience_depleted() -> void:
	# Do not play patience SFX if game is already over
	if not Global.is_game_over:
		if is_instance_valid(sfx_patience):
			sfx_patience.play()
	walk_out_queue(false)


func _on_patience_value_changed(new_value: float) -> void:
	if has_switched_to_angry:
		return
	if not is_instance_valid(patience_bar):
		return
	var max_val: float = max(1.0, float(patience_bar.max_value))
	var ratio: float = clamp(float(new_value) / max_val, 0.0, 1.0)
	var yellow_threshold: float = 0.25
	if "yellow_threshold" in patience_bar:
		yellow_threshold = patience_bar.yellow_threshold
	# switch to angry when entering orange range (below yellow threshold)
	if ratio < yellow_threshold:
		customer_sprite.texture = load(choosen_char[2])
		has_switched_to_angry = true


func random_char() -> void:
	choosen_char = characters[randi_range(0, len(characters)-1)]


func random_order():
	# 25% chance just drink order
	if randf() < 0.25:
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
	
	# 50% chance include es teh
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
		_spawn_feedback_particles_tex(particle_textures[0])
	else: # order failed
		customer_sprite.texture = load(choosen_char[2]) # angry face
		order_label.hide()
		# lose one life on failed order
		Global.lose_life(1)
		_spawn_feedback_particles_tex(particle_textures[1])
	choose_start_end_pos()
	await walk_to(start_end_pos)
	self.queue_free()


### choose random available queue slot
func choose_queue_slot() -> void:
	chosen_queue_slot = queue_layer.available_slot[randi_range(0, len(queue_layer.available_slot)-1)]
	queue_layer.use_slot(chosen_queue_slot)


func _spawn_feedback_particles(texture_path: String) -> void:
	# Backward-compatible wrapper for code paths that pass a resource path
	var tex: Texture2D = load(texture_path)
	_spawn_feedback_particles_tex(tex)


func _spawn_feedback_particles_tex(tex: Texture2D) -> void:
	if not is_instance_valid(particles) or tex == null:
		return
	particles.texture = tex
	# Emit using node-configured settings
	particles.emitting = false
	particles.restart()
	particles.emitting = true


func _prewarm_particles() -> void:
	# Run an invisible, minimal emit to compile shaders and upload textures
	if not is_instance_valid(particles):
		return
	var original_visible: bool = particles.visible
	var original_amount: int = particles.amount
	var original_one_shot: bool = particles.one_shot
	particles.visible = false
	particles.amount = 1
	particles.one_shot = true
	# Warm coin texture
	particles.texture = particle_textures[0]
	particles.emitting = true
	await get_tree().process_frame
	particles.emitting = false
	# Warm angry texture
	particles.texture = particle_textures[1]
	particles.emitting = true
	await get_tree().process_frame
	particles.emitting = false
	# Restore settings
	particles.amount = original_amount
	particles.one_shot = original_one_shot
	particles.visible = original_visible
