class_name CorridorDigger
extends Digger


signal corridor_dug


var corridor_width: int = 1
var corridor: Corridor2D

# Create a new Digger
func spawn(starting_position: Vector2, starting_direction: Vector2, new_boundary: Rect2, new_map: TileMap) -> void:
	print("Spawning new Corridor Digger")
	self.position = starting_position
	body.position = starting_position * 32
	self.boundary = new_boundary
	self.tile_map = new_map
	self.corridor = Corridor2D.new()
	if Globals.ui_config["draw_walls"]:
		add_child(self.corridor)

	# Corridor specific settings
	self.life_length = Globals.digger_config["corridor_life_length"]
	self.max_steps_to_turn = Globals.digger_config["corridor_max_steps_to_turn"]
	
	# get an initial direction facing
	turn(starting_direction)


# Main running loop for CorridorDigger
func live():
	dig_corridor()
	yield(self, "corridor_dug")
	print("Corridor Digger has no reason to live")


# Called on the death of a digger
func destroy() -> void:
	print("Destroying Corridor Digger")
	self.queue_free()


func dig_corridor() -> void:
	while life_length > 0:
		move()
		# See if we have already dug here
		if tile_map.get_cellv(self.position) != tile_map.INVALID_CELL:
			dig()
			corridor.add_point(self.position)
			if Globals.ui_config["animate"]:
				yield(get_tree().create_timer(self.wait_time), "timeout")

		if steps_since_turn >= max_steps_to_turn:
			turn(get_weighted_direction())
		
		life_length -= 1

	print("corridor dig job completed")
	emit_signal("corridor_dug")
