extends Node
class_name Digger

const DIRECTIONS = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]

var position: Vector2
var direction: Vector2

# Create a new Digger
func spawn(starting_position: Vector2) -> void:
	self.position = starting_position

# Get rid of a Digger
func destroy() -> void:
	queue_free()
