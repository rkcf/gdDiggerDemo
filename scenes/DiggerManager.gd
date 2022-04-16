class_name DiggerManager
extends Node


export (int) var max_width setget set_max_width
export (int) var max_height setget set_max_height
export (int) var cell_size
export (int) var n_generations # total number of generations of room diggers


var level_boundary: Rect2
var rooms: Array

var room_pick_method: int

var rng: RandomNumberGenerator = RandomNumberGenerator.new()

var planner: Planner

var room_digger = preload("res://scenes/RoomDigger.tscn")
var corridor_digger = preload("res://scenes/CorridorDigger.tscn")

onready var rooms_tile_map: TileMap = $RoomsTileMap
onready var corridors_tile_map: TileMap = $CorridorsTileMap
onready var diggers: Node = $Diggers # Digger node container
onready var room_container: Node = $Rooms
onready var ui = $UI/Control/UIPanel



func _ready() -> void:
	rng.randomize()
	# Connect to UI for config stuff
	ui.connect("ui_config_changed", self, "_handle_ui_config_change")
	load_config()

# Main level generation function
func generate_level() -> void:
	Globals.rooms = []
	self.rooms = Globals.rooms
	# Spawn an initial room digger somewhere around the middle
	self.level_boundary = Rect2(1, 1, max_width - 2, max_height - 2)
	
	# Spawn a new planner
	planner = Planner.new(level_boundary)
	
	var startx: int = round(rng.randfn(max_width / 2, max_width / 10))
	var starty: int = round(rng.randfn(max_height / 2, max_height / 10))
	var start_position: Vector2 = Vector2(startx, starty)
	
	var generation_room: Room2D = null # The starting room for the generation
	var rd: RoomDigger = null
	# Plot out a room
	var start_room: Room2D = planner.plot_room(start_position)

	rd = spawn_room_digger(start_room)
	if Globals.ui_config["animate"]:
		yield(rd.live(), "completed")
	else:
		rd.live()
	
#	print("Done yielding")
	if rd.room:
		add_room(rd.room)
		generation_room = rd.room
	rd.destroy()

	# Make sure we could make the generation starting room
	if generation_room == null:
		print("Early Exit. Could not make starting room")
	else:
		var generations_left: int = n_generations
		var generation_index: int = 0
		var next_room: Room2D = generation_room
		while generations_left > 0:
			if Globals.ui_config["animate"]:
				yield(spawn_generation(next_room), "completed")
				print("here")
			else:
				spawn_generation(next_room)
			print("Generation %s Finished" % generation_index)
			
			match room_pick_method:
				Globals.RoomPickMethods.RANDOM:
					next_room = rooms[randi() % rooms.size()]
				Globals.RoomPickMethods.FIRST:
					next_room = rooms[0]
				Globals.RoomPickMethods.LAST:
					next_room = rooms[rooms.size() - 1]
			generations_left -= 1
			generation_index += 1


# Spawn a generation from a starting room
func spawn_generation(generation_room: Room2D):
	# Spawn random number of corridor diggers, M=2 SD=1. Add 1 to make sure we always have 1
	var n_corridor_diggers: int = round(rng.randfn(2, 1) + 1) 
	
	while n_corridor_diggers > 0:
		var rand_wall: Dictionary = generation_room.random_wall()

		var cd: CorridorDigger = spawn_corridor_digger(rand_wall["position"], rand_wall["direction"])

		if Globals.ui_config["animate"]:
			yield(cd.live(), "completed") # Wait until cd has died to spawn a room digger here
		else:
			cd.live()
		if planner.check_if_good_to_build(cd.position): # This looks like a good place for a room
			# TODO somehow shift room position so the entrance isn't always top left
			var new_room: Room2D = planner.plot_room(cd.position)
			if new_room:
				add_room(new_room)
				var rd: RoomDigger = spawn_room_digger(new_room)
				if Globals.ui_config["animate"]:
					yield(rd.live(), "completed") # Wait until the digger has died to go onto the next Corridor
				else:
					rd.live()
				rd.destroy()
		else: # We don't want to build a room here. try again if enabled
			if Globals.digger_config["extend_corridors"]:
				cd.life_length = Globals.digger_config["corridor_life_length"] * 2
				if Globals.ui_config["animate"]:
					yield(cd.live(), "completed")
				else:
					cd.live()
				if planner.check_if_good_to_build(cd.position):
					var new_room: Room2D = planner.plot_room(cd.position)
					if new_room:
						add_room(new_room)
						var rd: RoomDigger = spawn_room_digger(new_room)
						if Globals.ui_config["animate"]:
							yield(rd.live(), "completed") # Wait until the digger has died to go onto the next Corridor
						else:
							rd.live()
						rd.destroy()


		cd.destroy()
		
		n_corridor_diggers -= 1



# Add a completed room so we can manage them later
func add_room(room: Room2D) -> void:
#	print(room)
	Globals.rooms.append(room)
	room_container.add_child(room)


func spawn_room_digger(room: Room2D) -> RoomDigger:
	var digger = room_digger.instance()
	diggers.add_child(digger)
	digger.spawn(room, self.rooms_tile_map)
	return digger


func spawn_corridor_digger(start_position: Vector2, start_direction: Vector2) -> CorridorDigger:
	var digger = corridor_digger.instance()
	diggers.add_child(digger)
	digger.spawn(start_position, start_direction, self.level_boundary, self.corridors_tile_map)
	return digger

# Reload the scene tree
func reload() -> void:
	cleanup()
	yield(get_tree().create_timer(.25), "timeout") # Wait for cleanup
	generate_level()


func cleanup() -> void:
	for digger in diggers.get_children():
		digger.queue_free()
	for room in room_container.get_children():
		room.queue_free()
	
	rooms = []
	
	for x in range(0, max_width):
		for y in range(0, max_height):
			rooms_tile_map.set_cell(x, y, rooms_tile_map.get_tileset().get_tiles_ids()[0])
			corridors_tile_map.set_cell(x, y, corridors_tile_map.get_tileset().get_tiles_ids()[0])


func set_max_width(value: int) -> void:
	max_width = value
	self.level_boundary = Rect2(1, 1, max_width - 2, max_height - 2)


func set_max_height(value: int) -> void:
	max_height = value
	self.level_boundary = Rect2(1, 1, max_width - 2, max_height - 2)


func load_config() -> void:
	self.max_height = Globals.gen_config["level_height"]
	self.max_width = Globals.gen_config["level_width"]
	self.cell_size = Globals.ui_config["cell_size"]
	self.n_generations = Globals.gen_config["n_generations"]
	self.room_pick_method = Globals.gen_config["room_pick_method"]


func _handle_ui_config_change() -> void:
	load_config()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_select"): # space bar
		reload()


func _on_GenerateButton_pressed() -> void:
	reload()
