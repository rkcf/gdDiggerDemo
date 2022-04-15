extends SpinBox
class_name ParamSpinbox


signal option_changed(spinbox)


export (Globals.ConfigDicts) var config_dict # which config dictionary it reaads from
export (String) var option # which option it applies to


func _ready() -> void:
	add_to_group("param_spinboxes")

#	var r = self.connect("changed", self, "_on_value_changed")
#	print(r)
#
#
#
#func _on_value_changed() -> void:
#	print("value change!!!d")
#	emit_signal("option_changed", self)
