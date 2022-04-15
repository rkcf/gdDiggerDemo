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


func _on_AnimateToggle_pressed() -> void:
	Globals.ui_config["animate"] = !Globals.ui_config["animate"]
	emit_signal("ui_config_changed")


func _on_DrawWallsToggle_pressed() -> void:
	Globals.ui_config["draw_walls"] =!Globals.ui_config["draw_walls"]
	emit_signal("ui_config_changed")


func _on_Generations_value_changed(value: float) -> void:
	Globals.gen_config["n_generations"] = round(value)
	emit_signal("ui_config_changed")


func _on_Width_value_changed(value: float) -> void:
	Globals.gen_config["level_width"] = round(value)
	emit_signal("ui_config_changed")


func _on_Height_value_changed(value: float) -> void:
	Globals.gen_config["level_height"] = round(value)
	emit_signal("ui_config_changed")
