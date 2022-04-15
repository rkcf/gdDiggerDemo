extends SpinBox
class_name ParamSpinbox


export (Globals.ConfigDicts) var config_dict # which config dictionary it reaads from
export (String) var option # which option it applies to


func _ready() -> void:
	add_to_group("param_spinboxes")
