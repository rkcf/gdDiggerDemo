extends PanelContainer


signal ui_config_changed

var drag_position = null


func _ready() -> void:
	# connect to parameter input scrollboxes
	for input in get_tree().get_nodes_in_group("param_spinboxes"):
		var r = input.connect("value_changed", self, "_handle_spinboxes", [input])
		print(r)

# To handle drag and movement of window
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


func _handle_spinboxes(value: float, input: ParamSpinbox) -> void:
	var dict: Dictionary
	match input.config_dict:
		Globals.ConfigDicts.UI_CONFIG:
			dict = Globals.ui_config
		Globals.ConfigDicts.GEN_CONFIG:
			dict = Globals.gen_config
		Globals.ConfigDicts.DIGGER_CONFIG:
			dict = Globals.digger_config
	dict[input.option] = value
	print(dict)
	emit_signal("ui_config_changed")


func _on_AnimateToggle_pressed() -> void:
	Globals.ui_config["animate"] = !Globals.ui_config["animate"]
	emit_signal("ui_config_changed")


func _on_DrawWallsToggle_pressed() -> void:
	Globals.ui_config["draw_walls"] =!Globals.ui_config["draw_walls"]
	emit_signal("ui_config_changed")


func _on_SimilarSizedRoomsToggle_pressed() -> void:
	Globals.digger_config["similar_sized_room"] = !Globals.digger_config["similar_sized_rooms"]
