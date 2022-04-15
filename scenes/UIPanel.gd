extends PanelContainer


var drag_position = null


func _on_UIPanel_gui_input(event: InputEvent) -> void:
	print("here")
	if event is InputEventMouseButton:
		if event.pressed:
			# drag the panel
			drag_position = get_global_mouse_position() - rect_global_position
		else:
			drag_position = null
	if event is InputEventMouseMotion and drag_position:
		rect_global_position = get_global_mouse_position() - drag_position
