class_name RoomDigger
extends Digger


var max_room_size: int = 15
var min_room_size: int = 4
var n_corridor_diggers: int # number of corridor diggers to spawn on death


func live() -> void:
	dig_room()
	destroy()


func destroy() -> void:
	# spawn between 1 and 4 corridor diggers
	self.n_corridor_diggers = round(rand_range(0, 4))
	for i in range(n_corridor_diggers):
		spawn_corridor_digger()
	# destroy self
	queue_free()


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


func spawn_corridor_digger() -> void:
	var digger = CorridorDigger.new()
	digger.spawn(self.position, self.boundary, self.tile_map)
	digger.live()
