tool
extends Control

signal install(package)
signal uninstall(package)
signal update(package)

var _info : Dictionary = {}
var _local : Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#    pass

func init_info(info: Dictionary, local: Dictionary) -> void:
    _info = info
    _local = local
    $info/box/name.text = info.name
    $info/box/version.text = 'Latest: %s'%info.latest_version
    var installed := false
    var latest := false
    if 'version' in _local:
        $info/box/box/installed.text = 'Installed: %s'%local.version
        installed = true
        latest = local.version == info.latest_version
        $info/box/box/android.visible = 'android' in local.platforms
        $info/box/box/ios.visible = 'ios' in local.platforms
    else:
        $info/box/box/installed.text = 'Not installed'
        $info/box/box/android.visible = false
        $info/box/box/ios.visible = false
    $bar/description.text = info.description
    $bar/controls/InstallButton.visible = not installed
    $bar/controls/UpdateButton.visible = not latest
    $bar/controls/UninstallButton.visible = installed

func _on_InstallButton_pressed() -> void:
    emit_signal('install', _info.name)

func _on_UninstallButton_pressed() -> void:
    emit_signal('uninstall', _info.name)

func _on_UpdateButton_pressed() -> void:
    emit_signal('update', _info.name)
