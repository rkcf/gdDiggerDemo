class_name CorridorDigger
extends Digger


var corridor_width: int = 1

# Create a new Digger
func spawn(starting_position: Vector2, new_boundary: Rect2, new_map: TileMap) -> void:
	randomize()
	print("Spawning new Corridor Digger")
	self.position = starting_position
	body.position = starting_position * 32
	self.boundary = new_boundary
	self.tile_map = new_map
	
	# Corridor specific settings
	self.life_length = 25
	self.max_steps_to_turn = 13
	
	# get an initial direction facing
	turn()


# Main running loop for CorridorDigger
func live() -> void:
	while life_length > 0:
		move()
		# See if we have already dug here
		if tile_map.get_cellv(self.position) != tile_map.INVALID_CELL:
			dig()
			yield(get_tree().create_timer(self.wait_time), "timeout")
		if steps_since_turn >= max_steps_to_turn:
			turn()
	destroy()


func destroy() -> void:
	# spawn new room digger
	print("CorridorDigger Died")
	emit_signal("digger_died", self)
