class_name DiggerManager
extends Node


export (int) var max_width = 60
export (int) var max_height = 34
export (int) var cell_size = 32
export (int) var n_generations = 1 # total number of generations of room diggers


var level_boundary: Rect2
var room_digger = preload("res://scenes/RoomDigger.tscn")
var corridor_digger = preload("res://scenes/CorridorDigger.tscn")

onready var tile_map: TileMap = $TileMap
onready var diggers: Node = $Diggers # Digger node container


func _ready() -> void:
	self.level_boundary = Rect2(1, 1, max_width - 2, max_height - 2)
	generate_level()

# Main level generation function
func generate_level() -> void:
	# Spawn an initial room digger
	var start_position: Vector2 = Vector2(round(rand_range(1, max_width - 1)), round(rand_range(1, max_height - 1)))
	var room: Room2D = null
	while n_generations > 0:
		room = create_room(start_position)

		# Spawn random number of corridor diggers
		var n_corridor_diggers: int = round(rand_range(0.5, 3))
		var cd: CorridorDigger
		for i in range(0, n_corridor_diggers):
			cd = spawn_corridor_digger(room.random_position())
			cd.live()
			yield(cd, "digger_died")
		# wait until last corridor diggers are destroyed to dig a room at the end
		

		# set the start position for the next generation to be in the last room generated in the current generation
		var rand_room_pos = room.random_position()

		# Make sure room_position is within boundaries
		if self.level_boundary.has_point(rand_room_pos):
			start_position = rand_room_pos
			n_generations -= 1
		else:
			print("Early Generation Extinction")


func create_room(start_position: Vector2) -> Room2D:
	var rd: RoomDigger = spawn_room_digger(start_position)
	rd.live()

	return(rd.room)


func spawn_room_digger(start_position: Vector2) -> RoomDigger:
	var digger = room_digger.instance()
	diggers.add_child(digger)
	digger.spawn(start_position, self.level_boundary, self.tile_map)
	return digger


func spawn_corridor_digger(start_position: Vector2) -> CorridorDigger:
	var digger = corridor_digger.instance()
	diggers.add_child(digger)
	digger.spawn(start_position, self.level_boundary, self.tile_map)
	return digger

# Reload the scene tree
func reload() -> void:
	get_tree().reload_current_scene()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		reload()
