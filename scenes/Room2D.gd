class_name Room2D
extends Node


var position: Vector2 # upper left position of room
var size: Vector2 # (width, height) vector giving size of the room
var area: Rect2


func _init(position: Vector2, size: Vector2):
	self.position = position
	self.size = size
	self.area = Rect2(self.position, self.size)
