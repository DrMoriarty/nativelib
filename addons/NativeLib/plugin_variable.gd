tool
extends HBoxContainer

var _var_name := ''

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#    pass

func setup(variable: String, params: Dictionary) -> void:
    _var_name = variable
    if 'info' in params:
        $var_desc.text = params.info
    if ProjectSettings.has_setting(variable):
        update_variable(ProjectSettings.get_setting(variable))
    else:
        update_variable('')

func _on_var_value_text_changed(new_text: String) -> void:
    update_variable(new_text)
    ProjectSettings.set_setting(_var_name, new_text)

func update_variable(value: String) -> void:
    if value == null or value == '':
        $var_value.modulate = Color.red
        $var_value.text = ''
    else:
        $var_value.text = value
        $var_value.modulate = Color.white
