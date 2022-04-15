extends Camera2D


func _input(event: InputEvent) -> void:
	if Input.is_action_just_released("ui_page_up"):
		self.zoom.x -= 0.1
		self.zoom.y -= 0.1	
	if Input.is_action_just_released("ui_page_down"):
		self.zoom.x += 0.1
		self.zoom.y += 0.1
