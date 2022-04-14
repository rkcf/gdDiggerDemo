class_name DiggerManager
extends Node


export (int) var max_width = 100
export (int) var max_height = 50


var level_border: Rect2


func _ready() -> void:
	level_border = Rect2(0, 0, max_width, max_height)
	generate_level()

# Main level generation function
func generate_level() -> void:
	# Spawn an initial room digger
	var digger: Digger = Digger.new()
	# Get a random starting location
	var start_position: Vector2 = Vector2(rand_range(1, max_width - 1), rand_range(1, max_height - 1))
	digger.spawn(start_position, level_border)
