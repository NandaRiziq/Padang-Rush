extends ProgressBar

@export var max_patience : int = 100
@export var decrease_amount : int = 5

var is_depleted:bool = false

signal patience_depleted


func _ready() -> void:
	self.max_value = max_patience
	self.value = max_value


func _process(delta: float) -> void:
	# when the bar runs out, return the process
	if is_depleted:
		return
	
	# decrease bar value over time
	if self.value > 0:
		self.value -= decrease_amount * delta
	# send signal when patience depleted
	else:
		is_depleted = true
		patience_depleted_announce()


func patience_depleted_announce() -> void:
	patience_depleted.emit()
	print('patience depleted!')
