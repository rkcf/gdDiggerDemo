class_name DiggerManager
extends Node


export (int) var max_width = 60
export (int) var max_height = 34
export (int) var cell_size = 32
export (int) var n_rooms = 9 # total number of room diggers to spawn


var level_boundary: Rect2


onready var tile_map: TileMap = $TileMap


func _ready() -> void:
	self.level_boundary = Rect2(1, 1, max_width - 2, max_height - 2)
	generate_level()

# Main level generation function
func generate_level() -> void:
	# Spawn an initial room digger
	var start_position: Vector2 = Vector2(round(rand_range(1, max_width - 1)), round(rand_range(1, max_height - 1)))
	while n_rooms > 0:
		create_room(start_position)


func create_room(start_position: Vector2) -> void:
	var rd: RoomDigger = spawn_room_digger(start_position)
	rd.live()
	# Spawn random number of corridor diggers
	var n_corridor_diggers: int = round(rand_range(0.5, 4))
	for i in range(0, n_corridor_diggers):
		var cd: CorridorDigger = spawn_corridor_digger(start_position)
		cd.live()
		# spawn a new room digger at the end of the corridor
		rd = spawn_room_digger(cd.position)
		rd.live()


func spawn_room_digger(start_position: Vector2) -> RoomDigger:
	self.n_rooms -= 1
	var digger: RoomDigger = RoomDigger.new()
	digger.spawn(start_position, self.level_boundary, self.tile_map)
	return digger


func spawn_corridor_digger(start_position: Vector2) -> CorridorDigger:
	var digger: CorridorDigger = CorridorDigger.new()
	digger.spawn(start_position, self.level_boundary, self.tile_map)
	return digger

# Reload the scene tree
func reload() -> void:
	get_tree().reload_current_scene()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		reload()
