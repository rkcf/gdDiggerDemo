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
	self.life_length = 16
	self.max_steps_to_turn = 8
	
	# get an initial direction facing
	turn()


func destroy() -> void:
	# spawn new room digger
	print("CorridorDigger Died")
	emit_signal("digger_died", self)
