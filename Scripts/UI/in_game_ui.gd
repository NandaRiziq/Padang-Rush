extends Control

@onready var heart_1: TextureRect = $MarginContainer/Control/Hearts2/HBoxContainer/Hearts1
@onready var heart_2: TextureRect = $MarginContainer/Control/Hearts2/HBoxContainer/Hearts2
@onready var heart_3: TextureRect = $MarginContainer/Control/Hearts2/HBoxContainer/Hearts3
@onready var money_label: Label = $MarginContainer/Control/HBoxContainer/MoneyLabel

var heart_full_color: Color = Color(1, 0.222965, 0.22643, 1)
var heart_empty_color: Color = Color8(67, 0, 3)


func _ready() -> void:
    # initialize from Global
    _update_money(Global.player_money)
    _update_hearts(Global.player_life)


    # connect to Global changes
    Global.money_changed.connect(_update_money)
    Global.life_changed.connect(_update_hearts)


func _update_money(value: int) -> void:
    if is_instance_valid(money_label):
        money_label.text = str(value)


func _update_hearts(life: int) -> void:
    var hearts: Array = [heart_3, heart_2, heart_1]
    for i in range(hearts.size()):
        var heart: TextureRect = hearts[i]
        if not is_instance_valid(heart):
            continue
        heart.modulate = heart_full_color if i < life else heart_empty_color


