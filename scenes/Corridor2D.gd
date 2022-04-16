extends Node
class_name Corridor2D

var line: Line2D # coordinates in tilemap position
var global_line: Line2D # global line positino for drawing
var rooms: Array # array of rooms we are connected to

func _init() -> void:
	self.rooms = []
	self.line = Line2D.new()
	self.global_line = Line2D.new()
	if Globals.ui_config["draw_walls"]:
		add_child(self.global_line)

# add a coordinate position 
func add_point(point: Vector2) -> void:
	line.add_point(point)
	global_line.add_point(point * 32)

# add a room we are connected to
func add_room(room: Room2D) -> void:
	rooms.append(room)
