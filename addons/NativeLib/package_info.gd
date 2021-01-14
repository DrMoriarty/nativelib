tool
extends Control

signal install(package)
signal uninstall(package)
signal update(package)

var _info : Dictionary = {}
var _local : Dictionary = {}
var _variables:= []

const plugin_variable = preload('res://addons/NativeLib/plugin_variable.tscn')

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#    pass

func init_info(info: Dictionary, local: Dictionary) -> void:
    for v in _variables:
        v.queue_free()
    _variables = []
    _info = info
    _local = local
    $box/left/plugin/name.text = info.name
    $box/left/license.text = 'License: %s'%info.license
    $box/left/version.text = 'Latest: %s'%info.version
    if 'updated' in info:
        $box/left/updated.text = 'Updated: %s'%[info.updated.split('T')[0]]
    else:
        $box/left/updated.text = ''
    if 'author' in _info:
        $box/left/author/AuthorButton.text = _info.author.name
        $box/left/author.show()
        $box/left/author/DonateButton.visible = 'donate' in _info.author
    else:
        $box/left/author.hide()
    var platforms = []
    if 'files' in _info:
        platforms.append('all')
    if 'platform_ios' in _info and 'files' in _info.platform_ios:
        platforms.append('ios')
    if 'platform_android' in _info and 'files' in _info.platform_android:
        platforms.append('android')
    $box/left/plugin/android.visible = 'android' in platforms
    $box/left/plugin/ios.visible = 'ios' in platforms
    $box/left/plugin/universal.visible = 'all' in platforms
    var installed := false
    var latest := false
    if 'version' in _local:
        $box/left/installed.show()
        $box/left/installed/version.text = 'Installed: %s'%local.version
        installed = true
        latest = local.version == info.version
        $box/left/installed/android.visible = 'android' in local.platforms
        $box/left/installed/ios.visible = 'ios' in local.platforms
        $box/left/installed/universal.visible = 'all' in local.platforms
    else:
        $box/left/installed.hide()
        #$box/left/installed/version.text = ''
        #$box/left/installed/android.visible = false
        #$box/left/installed/ios.visible = false
        #$box/left/installed/universal.visible = false
    $box/right/description.text = info.description
    $box/right/controls/InstallButton.visible = not installed
    $box/right/controls/UpdateButton.visible = not latest and installed
    $box/right/controls/UninstallButton.visible = installed
    if 'dependencies' in _local:
        $box/right/controls/deps.text = 'Depends on: %s'%PoolStringArray(_local.dependencies).join(', ')
    else:
        $box/right/controls/deps.text = ''
    if 'variables' in _local:
        $box/right/variables_title.show()
        for key in _local.variables:
            var vh = plugin_variable.instance()
            $box/right.add_child_below_node($box/right/variables_title, vh)
            _variables.append(vh)
            vh.setup(key, _local.variables[key])
    else:
        $box/right/variables_title.hide()

func _on_InstallButton_pressed() -> void:
    emit_signal('install', _info.name)

func _on_UninstallButton_pressed() -> void:
    emit_signal('uninstall', _info.name)

func _on_UpdateButton_pressed() -> void:
    emit_signal('update', _info.name)

func _on_InfoButton_pressed() -> void:
    if 'url' in _info:
        OS.shell_open(_info.url)

func _on_AuthorButton_pressed() -> void:
    if 'author' in _info and 'url' in _info.author:
        OS.shell_open(_info.author.url)

func _on_DonateButton_pressed() -> void:
    if 'author' in _info and 'donate' in _info.author:
        OS.shell_open(_info.author.donate)
