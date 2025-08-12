extends Control

@onready var heart_1: TextureRect = $MarginContainer/Control/Hearts2/HBoxContainer/Hearts1
@onready var heart_2: TextureRect = $MarginContainer/Control/Hearts2/HBoxContainer/Hearts2
@onready var heart_3: TextureRect = $MarginContainer/Control/Hearts2/HBoxContainer/Hearts3
@onready var money_label: Label = $MarginContainer/Control/HBoxContainer/MoneyLabel
@onready var pause_button: Button = $MarginContainer/Control/PauseButton
@onready var hearts_container: HBoxContainer = $MarginContainer/Control/Hearts2/HBoxContainer
@onready var money_container: HBoxContainer = $MarginContainer/Control/HBoxContainer

var pause_screen_scene: PackedScene = preload("res://Scenes/UI/pause_screen.tscn")
var final_screen_scene: PackedScene = preload("res://Scenes/UI/final_screen.tscn")
var bounce_component_scene: PackedScene = preload("res://Scenes/Components/bounce_component.tscn")

var money_bounce: Node
var hearts_bounce: Node

var heart_full_color: Color = Color(1, 0.222965, 0.22643, 1)
var heart_empty_color: Color = Color8(67, 0, 3)


func _ready() -> void:
    # initialize from Global
    _update_money(Global.player_money)
    _update_hearts(Global.player_life)


    # connect to Global changes
    Global.money_changed.connect(_update_money)
    Global.life_changed.connect(_update_hearts)
    Global.game_over.connect(_on_game_over)

    # pause button
    if is_instance_valid(pause_button):
        pause_button.pressed.connect(_on_pause_button_pressed)

    # attach bounce components
    if bounce_component_scene:
        if is_instance_valid(money_container):
            money_bounce = bounce_component_scene.instantiate()
            money_container.add_child(money_bounce)
        if is_instance_valid(hearts_container):
            hearts_bounce = bounce_component_scene.instantiate()
            hearts_container.add_child(hearts_bounce)


func _update_money(value: int) -> void:
    if is_instance_valid(money_label):
        money_label.text = str(value)
        if is_instance_valid(money_bounce):
            money_bounce.bounce()


func _update_hearts(life: int) -> void:
    var hearts: Array = [heart_3, heart_2, heart_1]
    for i in range(hearts.size()):
        var heart: TextureRect = hearts[i]
        if not is_instance_valid(heart):
            continue
        heart.modulate = heart_full_color if i < life else heart_empty_color
    if is_instance_valid(hearts_bounce):
        hearts_bounce.bounce()


func _on_pause_button_pressed() -> void:
    if get_tree().paused:
        return
    var pause_screen: Control = pause_screen_scene.instantiate()
    pause_screen.name = "PauseScreen"
    pause_screen.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
    pause_screen.mouse_filter = Control.MOUSE_FILTER_STOP
    add_child(pause_screen)
    # wiring buttons
    var continue_button: Button = pause_screen.get_node_or_null("VBoxContainer/Control/ButtonContainer/Continue")
    var restart_button: Button = pause_screen.get_node_or_null("VBoxContainer/Control/ButtonContainer/Restart")
    var main_menu_button: Button = pause_screen.get_node_or_null("VBoxContainer/Control/ButtonContainer/MainMenu")
    if is_instance_valid(continue_button):
        continue_button.pressed.connect(func() -> void:
            get_tree().paused = false
            pause_screen.queue_free()
        )
    if is_instance_valid(restart_button):
        restart_button.pressed.connect(func() -> void:
            get_tree().paused = false
            Global.reset_game_state()
            get_tree().change_scene_to_file("res://main.tscn")
        )
    if is_instance_valid(main_menu_button):
        main_menu_button.pressed.connect(func() -> void:
            get_tree().paused = false
            Global.reset_game_state()
            get_tree().change_scene_to_file("res://Scenes/UI/main_menu.tscn")
        )
    get_tree().paused = true


func _on_game_over() -> void:
    # Prevent duplicates
    if get_node_or_null("FinalScreen"):
        return
    var final_screen: Control = final_screen_scene.instantiate()
    final_screen.name = "FinalScreen"
    final_screen.process_mode = Node.PROCESS_MODE_INHERIT
    final_screen.mouse_filter = Control.MOUSE_FILTER_STOP
    add_child(final_screen)
    # Set final score label
    var score_label: Label = final_screen.get_node_or_null("Control/VBoxContainer/ScoreContainer/HBoxContainer/Score")
    if is_instance_valid(score_label):
        score_label.text = str(Global.player_money)
    # Wire buttons
    var restart_btn: Button = final_screen.get_node_or_null("Control/VBoxContainer/ButtonContainer/Restart")
    var main_menu_btn: Button = final_screen.get_node_or_null("Control/VBoxContainer/ButtonContainer/Button")
    if is_instance_valid(restart_btn):
        restart_btn.pressed.connect(func() -> void:
            get_tree().paused = false
            Global.reset_game_state()
            get_tree().change_scene_to_file("res://main.tscn")
        )
    if is_instance_valid(main_menu_btn):
        main_menu_btn.pressed.connect(func() -> void:
            get_tree().paused = false
            Global.reset_game_state()
            get_tree().change_scene_to_file("res://Scenes/UI/main_menu.tscn")
        )
    # Do not pause the game on game over; keep scene running for presentation
