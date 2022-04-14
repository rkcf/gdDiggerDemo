class_name DiggerManager
extends Node


export (int) var max_width = 60
export (int) var max_height = 34
export (int) var cell_size = 32



var level_boundary: Rect2


onready var tile_map: TileMap = $TileMap


func _ready() -> void:
	self.level_boundary = Rect2(1, 1, max_width - 2, max_height - 2)
	generate_level()

# Main level generation function
func generate_level() -> void:
	# Spawn an initial room digger
	var digger: Digger = Digger.new()
	# Get a random starting location
	var start_position: Vector2 = Vector2(round(rand_range(1, max_width - 1)), round(rand_range(1, max_height - 1)))
	digger.spawn(start_position, level_boundary, tile_map)

# Reload the scene tree
func reload() -> void:
	get_tree().reload_current_scene()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		reload()
