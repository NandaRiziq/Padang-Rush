extends Node2D

@onready var tap_component = $'../TapComponent'
@onready var es_teh_sprite_1: Sprite2D = $'../EsTehSprite1'
@onready var es_teh_sprite_2: Sprite2D = $'../EsTehSprite2'
@onready var timer: Timer = $'../Timer'
@onready var serving_plate = $'../../ServingPlate'
@onready var sfx_player: AudioStreamPlayer = $'../SFX_Refill'

var es_teh_amount: int = 0
var refill_time: float = 2.0


func _ready() -> void:
    # set refill time
    timer.wait_time = refill_time

    # connect tap component item_tapped
    tap_component.item_tapped.connect(use_es_teh)

    # connect timer timeout
    timer.timeout.connect(refill_es_teh)
 
    # hide nodes at start
    tap_component.hide()
    es_teh_sprite_1.hide()
    es_teh_sprite_2.hide()

    # sfx player is provided in scene as SFX_Refill


func refill_es_teh() -> void:
    # add es_teh_amount
    if es_teh_amount < 2:
        es_teh_amount += 1
        _play_refill_sfx()
    
    check_es_teh_amount()

    

func use_es_teh() -> void:
    # prevent es teh added if there is one at serving plate already
    if serving_plate and serving_plate.item_list.has("Es Teh"):
        return

    # remove es_teh_amount
    es_teh_amount -= 1
    check_es_teh_amount()

    #start timer
    timer.start()


func check_es_teh_amount() -> void:
    if es_teh_amount:
        tap_component.show()

    if es_teh_amount == 0:
        tap_component.hide()
        es_teh_sprite_1.hide()
        es_teh_sprite_2.hide()
    
    if es_teh_amount == 1:
        es_teh_sprite_1.show()
        es_teh_sprite_2.hide()
    
    if es_teh_amount == 2:
        es_teh_sprite_2.show()
        timer.stop()

func _play_refill_sfx() -> void:
    if not is_instance_valid(sfx_player):
        return
    sfx_player.play()



    