extends ProgressBar

@onready var customer: Node2D = $"../.."

@export var decrease_amount : int = 5

var is_depleted:bool = false
var is_bar_starting = false

signal patience_depleted


# Colors for the fill based on remaining patience ratio
@export var color_green: Color = Color(0.2, 0.8, 0.2)
@export var color_yellow: Color = Color(0.95, 0.85, 0.2)
@export var color_orange: Color = Color(1.0, 0.55, 0.0)
@export var color_red: Color = Color(1.0, 0.2, 0.2)

# Thresholds (ratio of value/max_value)
@export var green_threshold: float = 0.5
@export var yellow_threshold: float = 0.25
@export var orange_threshold: float = 0.125

var _fill_style: StyleBoxFlat
var _current_bucket: int = -1


func _ready() -> void:
	customer.order_ready.connect(start_patience_bar)
	self.max_value = Global.customer_patience
	self.value = max_value
	_update_fill_color()


func _process(delta: float) -> void:
	# when the bar runs out, return the process
	if is_depleted:
		return
	
	# decrease bar value over time
	if is_bar_starting:
		if self.value > 0:
			self.value -= decrease_amount * delta
			_update_fill_color()
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


func _update_fill_color() -> void:
	# Guard against divide by zero
	var max_val: float = max(1.0, float(self.max_value))
	var patience_ratio: float = clamp(float(self.value) / max_val, 0.0, 1.0)

	var bucket: int
	if patience_ratio >= green_threshold:
		bucket = 3 # green
	elif patience_ratio >= yellow_threshold:
		bucket = 2 # yellow
	elif patience_ratio >= orange_threshold:
		bucket = 1 # orange
	else:
		bucket = 0 # red

	if bucket == _current_bucket and _fill_style:
		return

	_current_bucket = bucket
	if not _fill_style:
		var existing_fill: StyleBox = get_theme_stylebox("fill")
		var existing_flat: StyleBoxFlat = existing_fill as StyleBoxFlat
		if existing_flat:
			_fill_style = existing_flat.duplicate() as StyleBoxFlat
			if _fill_style:
				_fill_style.resource_local_to_scene = true
		else:
			_fill_style = StyleBoxFlat.new()
		add_theme_stylebox_override("fill", _fill_style)

	match bucket:
		3:
			_fill_style.bg_color = color_green
		2:
			_fill_style.bg_color = color_yellow
		1:
			_fill_style.bg_color = color_orange
		_:
			_fill_style.bg_color = color_red


 
