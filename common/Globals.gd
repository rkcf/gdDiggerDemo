extends Node

enum ConfigDicts {UI_CONFIG, GEN_CONFIG, DIGGER_CONFIG}
enum RoomPickMethods {RANDOM, FIRST, LAST}

# Configuration for UI type stuff
var ui_config: Dictionary = {
	"animate": false, # Whether we animate the digging process
	"draw_walls": false, # Whether we draw red rects around rooms
	"cell_size":  32 # Size of the cells we are drawing
}

# Generation parameters
var gen_config: Dictionary = {
	"level_width": 300,
	"level_height": 150,
	"n_generations": 3,  # Number of generations to run
	"room_pick_method": RoomPickMethods.RANDOM # How we pick the room to spawn each generation out of
}

# Digger specific parameters
var digger_config: Dictionary = {
	"max_room_size": 10,
	"min_room_size": 3,
	"similar_sized_rooms": true,
	"corridor_life_length": 18,
	"corridor_max_steps_to_turn": 14
}

