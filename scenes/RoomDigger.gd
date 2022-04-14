class_name RoomDigger
extends Digger


var max_room_size: int = 10
var min_room_size: int = 4


func live() -> void:
	dig_room()
	destroy()


func destroy() -> void:
	print("RoomDigger Died")
	emit_signal("digger_died", self)


func dig_room() -> void:
	print("Digging Room at %s" % self.position)
	var width: int = round(rand_range(min_room_size, max_room_size))
	var height: int = round(rand_range(min_room_size, max_room_size))
	var size: Vector2 = Vector2(width, height)
	var top_corner: Vector2 = (position - size/2).ceil()
	for x in size.x:
		for y in size.y:
			var next_dig = top_corner + Vector2(x, y)
			if self.boundary.has_point(next_dig):
				self.position = next_dig
				dig()
