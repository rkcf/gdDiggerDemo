extends PanelContainer


signal ui_config_changed

var drag_position = null


func _on_UIPanel_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			if Input.is_action_pressed("left_click"):
				# drag the panel
				drag_position = get_global_mouse_position() - rect_global_position
		else:
			drag_position = null
	if event is InputEventMouseMotion and drag_position:
		rect_global_position = get_global_mouse_position() - drag_position


func _on_CheckBox_pressed() -> void:
	pass # Replace with function body.


func _on_AnimateToggle_pressed() -> void:
	Globals.config["animate"] = !Globals.config["animate"]
	emit_signal("ui_config_changed")
