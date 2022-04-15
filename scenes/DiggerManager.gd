class_name DiggerManager
extends Node


signal generation_finished


export (int) var max_width = 300 setget set_max_width
export (int) var max_height = 150 setget set_max_height
export (int) var cell_size = 32
export (int) var n_generations = 20 setget set_n_generations# total number of generations of room diggers

var generations_left: int
var level_boundary: Rect2
var rooms: Array = []

var rng: RandomNumberGenerator = RandomNumberGenerator.new()

var room_digger = preload("res://scenes/RoomDigger.tscn")
var corridor_digger = preload("res://scenes/CorridorDigger.tscn")

onready var rooms_tile_map: TileMap = $RoomsTileMap
onready var corridors_tile_map: TileMap = $CorridorsTileMap
onready var diggers: Node = $Diggers # Digger node container
onready var generation_input: SpinBox = $UI/Control/UIPanel/NinePatchRect/MarginContainer/VBoxContainer/BottomRow/Generations/Generations
onready var max_width_input: SpinBox = $UI/Control/UIPanel/NinePatchRect/MarginContainer/VBoxContainer/BottomRow/Width/Width
onready var max_height_input: SpinBox = $UI/Control/UIPanel/NinePatchRect/MarginContainer/VBoxContainer/BottomRow/Height/Height
onready var ui = $UI/Control/UIPanel


func _ready() -> void:
	
	# Connect to UI for config stuff
	ui.connect("ui_config_changed", self, "_handle_ui_config_change")
	
	self.level_boundary = Rect2(1, 1, max_width - 2, max_height - 2)

# Main level generation function
func generate_level() -> void:
	rng.randomize()
	# Spawn an initial room digger somewhere around the middle
	var startx: int = round(rng.randfn(max_width / 2, max_width / 10))
	var starty: int = round(rng.randfn(max_height / 2, max_height / 10))
	var start_position: Vector2 = Vector2(startx, starty)
	
	var generation_room: Room2D = null # The starting room for the generation
	var rd: RoomDigger = null
	rd = spawn_room_digger(start_position)
	rd.live()
	yield(rd, "job_completed")
	rooms.append(rd.room)
	generation_room = rd.room
	rd.destroy()

	# Make sure we could make the generation starting room
	if generation_room == null:
		pass # TODO add an actual check for starting room

	self.generations_left = n_generations
	var next_room: Room2D = generation_room
	while generations_left > 0:
		spawn_generation(next_room)
		yield(self, "generation_finished")
		next_room = rooms[randi() % rooms.size()]
		n_generations -= 1


# Spawn a generation from a starting room
func spawn_generation(generation_room: Room2D):
	# Spawn random number of corridor diggers, M=2 SD=1
	var n_corridor_diggers: int = round(rng.randfn(2, 1))
	var cd: CorridorDigger = null
	
	for i in range(0, n_corridor_diggers):
		var rd: RoomDigger = null
		var rand_wall = generation_room.random_wall()
		if self.level_boundary.has_point(rand_wall):
			cd = spawn_corridor_digger(rand_wall)
			cd.live()
			yield(cd, "job_completed") # Wait until cd has died to spawn a room digger here
			rd = spawn_room_digger(cd.position)
			rd.live()
			yield(rd, "job_completed") # Wait until the digger has died to go onto the next Corridor
			rooms.append(rd.room)
			
			cd.destroy()
			rd.destroy()

	emit_signal("generation_finished")


func create_room(start_position: Vector2) -> RoomDigger:
	var rd: RoomDigger = spawn_room_digger(start_position)
	rd.live()
	return(rd)


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
	yield(get_tree().create_timer(.25), "timeout") # Wait for cleanup
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


func _handle_ui_config_change() -> void:
	# reload config
	pass




func _on_GenerateButton_pressed() -> void:
	reload()
	


func _on_Generations_value_changed(value: float) -> void:
	self.n_generations = round(value)


func _on_Width_value_changed(value: float) -> void:
	self.max_width = round(value)
	


func _on_Height_value_changed(value: float) -> void:
	self.max_height = round(value)
