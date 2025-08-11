extends Node2D

@onready var timer: Timer = $OffQueueLayer/CustomerSpawner/Timer

var menu: menu_resource = menu_resource.new()
var elapsed_time: float = 0.0
var current_time: String = "00:00"
var current_second: int = 0
var is_timer_running: bool = false
var last_second: int = -1

signal second_passed


func _ready() -> void:
	start_timer()


func _process(delta: float) -> void:
	if is_timer_running:
		elapsed_time += delta
		current_second = int(elapsed_time)

		if last_second != current_second:
			last_second = current_second
			format_time(elapsed_time)
			second_passed.emit()

			# add game difficulty every 20 seconds
			if current_second > 0 and current_second % 25 == 0:
				Global.game_difficulty += 1

				# decrease spawn delay every 2 level, until 0
				if Global.game_difficulty % 2 == 0:
					Global.spawn_delay -= 0.5
					timer.wait_time = Global.spawn_delay
					print("Spawn delay decreased to ", Global.spawn_delay)

					# decrease customer patience every 2 level, until 50
					if Global.customer_patience > 50:
						Global.customer_patience -= 5
						print("Customer patience decreased to ", Global.customer_patience)

				# add allowed customers until max main dish amount
				if Global.allowed_customers < 4:
					Global.allowed_customers += 1
					print("Allowed customers increased to ", Global.allowed_customers)
				
				# add allowed main dish until 4 max (start from level 6)
				if Global.game_difficulty >= 6:
					if Global.allowed_main_dish < menu.main_dish.size():
						Global.allowed_main_dish += 1
						print("Allowed main dish increased to ", Global.allowed_main_dish)


func start_timer() -> void:
	is_timer_running = true


func stop_timer() -> void:
	is_timer_running = false


func format_time(seconds: float) -> void:
	var minutes = int(seconds / 60)
	var secs = int(seconds) % 60
	current_time = "%02d:%02d" % [minutes, secs]