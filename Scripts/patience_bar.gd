extends ProgressBar

@onready var customer: Node2D = $"../.."

@export var max_patience : int = 100
@export var decrease_amount : int = 5

var is_depleted:bool = false
var is_bar_starting = false

signal patience_depleted


func _ready() -> void:
	customer.order_ready.connect(start_patience_bar)
	self.max_value = max_patience
	self.value = max_value


func _process(delta: float) -> void:
	# when the bar runs out, return the process
	if is_depleted:
		return
	
	# decrease bar value over time
	if is_bar_starting:
		if self.value > 0:
			self.value -= decrease_amount * delta
		# send signal when patience depleted
		else:
			is_depleted = true
			patience_depleted_announce()


func patience_depleted_announce() -> void:
	patience_depleted.emit()
	#print('patience depleted!')


func start_patience_bar() -> void:
	is_bar_starting = true


func stop_patience_bar() -> void:
	is_bar_starting = false
