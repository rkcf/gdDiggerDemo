class_name DiggerManager
extends Node


export (int) var max_width = 300 setget set_max_width
export (int) var max_height = 150 setget set_max_height
export (int) var cell_size = 32
export (int) var n_generations = 20 setget set_n_generations# total number of generations of room diggers

var generations_left: int
var level_boundary: Rect2

var rng: RandomNumberGenerator = RandomNumberGenerator.new()

var room_digger = preload("res://scenes/RoomDigger.tscn")
var corridor_digger = preload("res://scenes/CorridorDigger.tscn")

onready var rooms_tile_map: TileMap = $RoomsTileMap
onready var corridors_tile_map: TileMap = $CorridorsTileMap
onready var diggers: Node = $Diggers # Digger node container
onready var generation_input: SpinBox = $UI/Control/UIPanel/MarginContainer/VBoxContainer/HBoxContainer/Generations/Generations
onready var max_width_input: SpinBox = $UI/Control/UIPanel/MarginContainer/VBoxContainer/HBoxContainer/Width/Width
onready var max_height_input: SpinBox = $UI/Control/UIPanel/MarginContainer/VBoxContainer/HBoxContainer/Height/Height


func _ready() -> void:
	self.level_boundary = Rect2(1, 1, max_width - 2, max_height - 2)

# Main level generation function
func generate_level() -> void:
	rng.randomize()
	# Spawn an initial room digger somewhere around the middle
	var startx: int = round(rng.randfn(max_width / 2, max_width / 10))
	var starty: int = round(rng.randfn(max_height / 2, max_height / 10))
	var start_position: Vector2 = Vector2(startx, starty)
	
	self.generations_left = n_generations
	while generations_left > 0:
		# cleanup diggers from previous generation
		# TODO FIXME need to add some sort of wait here for room diggers to finish
#		for digger in diggers.get_children():
#			digger.queue_free()
		var room: Room2D = null
		room = create_room(start_position)
		
		# Make sure we could make the generation starting room
		print(room)
		if room == null:
			break

		# Spawn random number of corridor diggers, M=3 SD=2
		var n_corridor_diggers: int = round(rng.randfn(3, 1))
		var cd: CorridorDigger
		for i in range(0, n_corridor_diggers):
			# TODO FIXME periodic bug where we get to this point when room == null even with previous check
			var rand_wall = room.random_wall()
			if self.level_boundary.has_point(rand_wall):
				cd = spawn_corridor_digger(room.random_wall())
				cd.live()
				yield(cd, "digger_died")
				room = create_room(cd.position)
				if room == null:
					break

		# set the start position for the next generation to be in the last room generated in the current generation
		if room:
			var rand_room_pos = room.random_position()
			
			# Make sure room_position is within boundaries
			if self.level_boundary.has_point(rand_room_pos):
				start_position = rand_room_pos
				self.generations_left -= 1
			else:
				print("Early Generation Extinction")
		else:
			break


func create_room(start_position: Vector2) -> Room2D:
	var rd: RoomDigger = spawn_room_digger(start_position)
	rd.live()
	return(rd.room)


func spawn_room_digger(start_position: Vector2) -> RoomDigger:
	var digger = room_digger.instance()
	diggers.add_child(digger)
	digger.spawn(start_position, self.level_boundary, self.rooms_tile_map)
	return digger


func spawn_corridor_digger(start_position: Vector2) -> CorridorDigger:
	var digger = corridor_digger.instance()
	diggers.add_child(digger)
	digger.spawn(start_position, self.level_boundary, self.corridors_tile_map)
	return digger

# Reload the scene tree
func reload() -> void:
	cleanup()
#	yield(get_tree().create_timer(1), "timeout") # Wait 1 second for cleanup
	generate_level()


func cleanup() -> void:
	for digger in diggers.get_children():
		digger.queue_free()
	for x in range(0, max_width):
		for y in range(0, max_height):
			rooms_tile_map.set_cell(x, y, rooms_tile_map.get_tileset().get_tiles_ids()[0])
			corridors_tile_map.set_cell(x, y, corridors_tile_map.get_tileset().get_tiles_ids()[0])


func set_n_generations(value: int) -> void:
	n_generations = value
	generation_input.value = value


func set_max_width(value: int) -> void:
	max_width = value
	max_width_input.value = value
	self.level_boundary = Rect2(1, 1, max_width - 2, max_height - 2)


func set_max_height(value: int) -> void:
	max_height = value
	max_height_input.value = value
	self.level_boundary = Rect2(1, 1, max_width - 2, max_height - 2)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_select"): # space bar
		reload()


func _on_GenerateButton_pressed() -> void:
	reload()
	


func _on_Generations_value_changed(value: float) -> void:
	self.n_generations = round(value)


func _on_Width_value_changed(value: float) -> void:
	self.max_width = round(value)
	


func _on_Height_value_changed(value: float) -> void:
	self.max_height = round(value)
