extends Node2D

var foods:Array = [
	preload("res://Assets/Food/ayam.png"),
	preload("res://Assets/Food/rendang.png"),
	preload("res://Assets/Food/telor.png"),
	preload("res://Assets/Food/daun.png"),
	preload("res://Assets/Food/sambel.png"),
	preload("res://Assets/Food/es teh.png")
]
@export_enum("ayam", "rendang", "telor", "daun", "sambel", "es teh") var food_list:int = 0
