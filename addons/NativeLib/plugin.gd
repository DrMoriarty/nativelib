# Plugin NativeLib : MIT License
# @author DrMoriarty
tool
extends EditorPlugin

const IconResource = preload("res://addons/NativeLib/icons/phone.svg")
const MainUI = preload("res://addons/NativeLib/MainUI.tscn")

var _main_ui

func _enter_tree():
    _main_ui = MainUI.instance()
    get_editor_interface().get_editor_viewport().add_child(_main_ui)
    _main_ui.set_editor(self)
    make_visible(false)

func _exit_tree():
    if _main_ui:
        _main_ui.queue_free()

func has_main_screen():
    return true

func make_visible(visible):
    if _main_ui:
        _main_ui.visible = visible

func get_plugin_name():
    return "NativeLib"

func get_plugin_icon():
    return IconResource

func save_external_data():
    if _main_ui:
        _main_ui.save_data()
