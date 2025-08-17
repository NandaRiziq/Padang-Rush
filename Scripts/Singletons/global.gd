extends Node

var game_difficulty: int = 1
var allowed_customers: int = 1
var allowed_main_dish: int = 1
var spawn_delay: float = 4.0
var customer_patience: int = 100
var player_life: int = 3
var player_money: int = 0
var is_game_over: bool = false

signal money_changed(new_value: int)
signal life_changed(new_value: int)
signal game_over()


func reset_game_state() -> void:
	game_difficulty = 1
	allowed_customers = 1
	allowed_main_dish = 1
	spawn_delay = 4.0
	customer_patience = 100
	player_life = 3
	player_money = 0
	is_game_over = false
	money_changed.emit(player_money)
	life_changed.emit(player_life)

func add_money(amount: int) -> void:
	player_money += amount
	money_changed.emit(player_money)

func lose_life(amount: int = 1) -> void:
	player_life = max(0, player_life - amount)
	life_changed.emit(player_life)
	if player_life <= 0 and not is_game_over:
		is_game_over = true
		game_over.emit()
		print("Game over!")