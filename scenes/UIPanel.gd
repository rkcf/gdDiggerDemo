extends PanelContainer


signal ui_config_changed

var drag_position = null


func _ready() -> void:
	# connect to parameter input scrollboxes
	for input in get_tree().get_nodes_in_group("param_spinboxes"):
		input.connect("value_changed", self, "_handle_spinboxes", [input])

	# connect to parameter toggles
	for input in get_tree().get_nodes_in_group("param_toggles"):
		input.connect("pressed", self, "_handle_toggles", [input])
		
	set_ui_values()

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


func _handle_toggles(input: ParamToggle) -> void:
	var dict: Dictionary
	match input.config_dict:
		Globals.ConfigDicts.UI_CONFIG:
			dict = Globals.ui_config
		Globals.ConfigDicts.GEN_CONFIG:
			dict = Globals.gen_config
		Globals.ConfigDicts.DIGGER_CONFIG:
			dict = Globals.digger_config
	dict[input.option] = !dict[input.option]
	emit_signal("ui_config_changed")

func set_ui_values() -> void:
	for input in get_tree().get_nodes_in_group("param_spinboxes"):
		var dict: Dictionary
		match input.config_dict:
			Globals.ConfigDicts.UI_CONFIG:
				dict = Globals.ui_config
			Globals.ConfigDicts.GEN_CONFIG:
				dict = Globals.gen_config
			Globals.ConfigDicts.DIGGER_CONFIG:
				dict = Globals.digger_config
		input.value = dict[input.option]
	for input in get_tree().get_nodes_in_group("param_toggles"):
		var dict: Dictionary
		match input.config_dict:
			Globals.ConfigDicts.UI_CONFIG:
				dict = Globals.ui_config
			Globals.ConfigDicts.GEN_CONFIG:
				dict = Globals.gen_config
			Globals.ConfigDicts.DIGGER_CONFIG:
				dict = Globals.digger_config
		input.pressed = dict[input.option]
		
