extends Node


export (int) var max_width = 100
export (int) var max_height = 50

func _ready() -> void:
	generate_level()


# Main level generation function
func generate_level() -> void:
	# Spawn an initial room digger
	var digger: Digger = Digger.new()
	# Get a random starting location
	var start_position: Vector2 = Vector2(rand_range(1, max_width), rand_range(1, max_height))
	digger.spawn(start_position)
