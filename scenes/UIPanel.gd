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
		
	# connect to parameter option buttons
	for input in get_tree().get_nodes_in_group("param_options"):
		var r = input.connect("item_selected", self, "_handle_options", [input])
		print(r)
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
	var dict = get_config_dict(input.config_dict)
	dict[input.option] = value
	emit_signal("ui_config_changed")


func _handle_toggles(input: ParamToggle) -> void:
	var dict = get_config_dict(input.config_dict)
	dict[input.option] = !dict[input.option]
	emit_signal("ui_config_changed")


func _handle_options(_index: int, input: ParamOption) -> void:
	var dict = get_config_dict(input.config_dict)
	dict[input.option] = input.selected
	emit_signal("ui_config_changed")


func set_ui_values() -> void:
	for input in get_tree().get_nodes_in_group("param_spinboxes"):
		var dict = get_config_dict(input.config_dict)
		input.value = dict[input.option]
	for input in get_tree().get_nodes_in_group("param_toggles"):
		var dict = get_config_dict(input.config_dict)
		input.pressed = dict[input.option]
	for input in get_tree().get_nodes_in_group("param_options"):
		var dict = get_config_dict(input.config_dict)
		input.selected = dict[input.option]


func get_config_dict(index: int) -> Dictionary:
	var dict: Dictionary
	match index:
		Globals.ConfigDicts.UI_CONFIG:
			dict = Globals.ui_config
		Globals.ConfigDicts.GEN_CONFIG:
			dict = Globals.gen_config
		Globals.ConfigDicts.DIGGER_CONFIG:
			dict = Globals.digger_config
	return dict
