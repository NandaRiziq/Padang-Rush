extends Node2D

@onready var patience_bar: ProgressBar = $OrderLabel/PatienceBar


func _ready() -> void:
	# delete customer upon patience depleted
	patience_bar.patience_depleted.connect(func free_customer() -> void:
		self.queue_free()
	)
