tool
extends Control

const package_info = preload('res://addons/NativeLib/package_info.tscn')
const _local_nativelib := 'addons/NativeLib/nativelib'
const _remote_url := 'https://raw.githubusercontent.com/DrMoriarty/nativelib-cli/HEAD/nativelib'

var _STORAGE := {}
var _PROJECT := {}
var _filter := ''
var _NL_GLOBAL := true
var _platform_filter := []
var _name_filter := ''
var _nativelib_path := '/usr/local/bin/nativelib'
var _python_path := 'python'
onready var _home_path := '%s/../'%OS.get_system_dir(OS.SYSTEM_DIR_DESKTOP)

signal downloading_complete

enum Errors {NO_ERROR = 0, NATIVELIB_ERROR = 1, PYTHON_ERROR = 2}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    if ProjectSettings.has_setting('NativeLib/Python'):
        _python_path = ProjectSettings.get_setting('NativeLib/Python')

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#    pass

func save_data() -> void:
    pass

func show_global_error(err: String) -> void:
    $view/panel/error.text = err
    $view/panel/error.show()
    $view/panel/scroll.hide()

func hide_global_error() -> void:
    $view/panel/error.hide()
    $view/panel/scroll.show()

func check_system() -> int:
    hide_global_error()
    var err = Errors.NO_ERROR
    var python = run_command(_python_path, ['--version'], false)
    var python_ver = python[0].replace('\n', '')
    if python_ver == '':
        show_global_error('Python not found. You should install python into your system and setup it\'s path.')
        $view/status/python.text = 'Python not found'
        $view/status/python.modulate = Color.red
        err = Errors.PYTHON_ERROR
    else:
        $view/status/python.text = python_ver
        $view/status/python.modulate = Color.white
        # get home path
        var pp = run_command(_python_path, ['-c', "import os; print(os.path.expanduser('~'));"], false)
        var hp = pp[0].replace('\n', '')
        if hp != '':
            _home_path = hp
    
    var f = File.new()
    if f.file_exists('res://'+_local_nativelib):
        _NL_GLOBAL = false
    elif f.file_exists(_nativelib_path):
        _NL_GLOBAL = true
    var output = nativelib(['--version'], false)
    var ver = output[0].replace('\n', '')
    var s = ''
    var col := Color.white
    if ver == '':
        s = 'NativeLib not found'
        col = Color.red
        err = max(err, Errors.NATIVELIB_ERROR)
        $view/status/InstallSystemButton.visible = true
        $view/status/UpdateSystemButton.visible = false
    elif _NL_GLOBAL:
        s = 'NativeLib'
        col = Color.lightblue
        err = Errors.NO_ERROR
        $view/status/InstallSystemButton.visible = true
        $view/status/UpdateSystemButton.visible = false
    else:
        s = 'NativeLib'
        col = Color.lightgreen
        err = Errors.NO_ERROR
        $view/status/InstallSystemButton.visible = false
        $view/status/UpdateSystemButton.visible = true
    $view/status/system.text = '%s %s'%[s, ver]
    $view/status/system.modulate = col
    if err == Errors.NO_ERROR:
        hide_global_error()
    return err

func set_editor(editor: EditorPlugin) -> void:
    yield(get_tree(), 'idle_frame')
    var err = check_system()
    match err:
        Errors.PYTHON_ERROR:
            return
        Errors.NATIVELIB_ERROR:
            push_warning('NativeLib not installed in system. Making a local copy...')
            install_local_nativelib()
            yield(self, 'downloading_complete')
            if check_system() != Errors.NO_ERROR:
                return
            nativelib(['--update'])
        Errors.NO_ERROR:
            pass
    load_storage()
    nativelib(['--prepare'])
    load_project()
    update_project_info()
    update_plugin_list()
    update_status()

func load_storage() -> void:
    var storage_path = '%s/.nativelib/storage'%_home_path
    var f = File.new()
    if f.open(storage_path, File.READ) != OK:
        push_error('NativeLib repository not found! Search at %s'%storage_path)
        return
    var content = f.get_as_text()
    f.close()
    var result = JSON.parse(content)
    if result.error == OK:
        _STORAGE = result.result
    else:
        push_error('Can not read NativeLib storage. Is it correctly installed?')

func load_project() -> void:
    var f = File.new()
    if f.open('res://.nativelib', File.READ) != OK:
        push_warning('NativeLib not initialized yet')
        return
    var content = f.get_as_text()
    f.close()
    var result = JSON.parse(content)
    if result.error == OK:
        _PROJECT = result.result
    else:
        push_error('Can not read NativeLib project meta data.')

func update_plugin_list() -> void:
    for ch in $view/panel/scroll/margin/list.get_children():
        ch.queue_free()
    var keys = _STORAGE.keys()
    keys.sort()
    for plugin in keys:
        var info = _STORAGE[plugin]
        var platforms = []
        var files = info.versions[info.latest_version]
        for f in files:
            var fns = f.name.split('_')
            var pls = fns[-1].split('.')
            platforms.append(pls[0])
        var filtered_out := false
        if _platform_filter.size() > 0:
            for pl in _platform_filter:
                if not pl in platforms:
                    filtered_out = true
                    break
        if _name_filter.length() > 0:
            var ff = _name_filter.to_lower()
            var nn = info.name.to_lower()
            var dd = info.description.to_lower()
            if nn.find(ff) < 0 and dd.find(ff) < 0:
                filtered_out = true
        if filtered_out:
            continue
        var pi = package_info.instance()
        var local = {}
        if 'packages' in _PROJECT:
            if plugin in _PROJECT.packages:
                local = _PROJECT.packages[plugin]
        pi.init_info(info, local)
        pi.connect('install', self, '_on_plugin_install')
        pi.connect('uninstall', self, '_on_plugin_uninstall')
        pi.connect('update', self, '_on_plugin_update')
        $view/panel/scroll/margin/list.add_child(pi)

func get_installed_packages() -> Array:
    var result := []
    if 'packages' in _PROJECT:
        for p in _PROJECT.packages:
            result.append(p)
    return result

func update_project_info() -> void:
    if 'platforms' in _PROJECT:
        $view/project/iOSButton.pressed = 'ios' in _PROJECT.platforms
        $view/project/AndroidButton.pressed = 'android' in _PROJECT.platforms
    else:
        $view/project/iOSButton.pressed = false
        $view/project/AndroidButton.pressed = false

func update_status() -> void:
    $view/status/info.text = '%d packages in repository, %d installed'%[_STORAGE.keys().size(), get_installed_packages().size()]

func install_local_nativelib() -> void:
    var http_request = HTTPRequest.new()
    http_request.name = 'HTTP'
    add_child(http_request)
    http_request.connect('request_completed', self, '_http_request_completed')
    var error = http_request.request(_remote_url)
    if error != OK:
        push_error('HTTP error %d. Can not download a local copy of NativeLib'%error)

func _http_request_completed(result, response_code, headers, body) -> void:
    if response_code >= 300:
        push_error('HTTP response code: %d'%response_code)
    else:
        var f = File.new()
        if f.open('res://'+_local_nativelib, File.WRITE) != OK:
            push_error('Can not save NativeLib to file %s'%['res://'+_local_nativelib])
            return
        f.store_buffer(body)
        f.close()
        #run_command('chmod', ['+x', _local_nativelib])
        print('Installed %s (%d bytes)'%[_local_nativelib, body.size()])
        _NL_GLOBAL = false
    emit_signal('downloading_complete')
    get_node('HTTP').queue_free()

func _on_UpdateRepoButton_pressed() -> void:
    nativelib(['--update'])
    load_storage()
    update_plugin_list()
    update_status()

func _on_plugin_install(package: String) -> void:
    nativelib(['--install', package])
    load_project()
    update_status()
    # update settings for new packages
    if 'packages' in _PROJECT:
        for package in _PROJECT.packages:
            var info = _PROJECT.packages[package]
            if 'android_module' in info:
                add_android_module(info.android_module)
            if 'autoload' in info:
                for key in info.autoload:
                    var ss = 'autoload/%s'%key
                    if not ProjectSettings.has_setting(ss):
                        ProjectSettings.set_setting(ss, info.autoload[key])
            if 'variables' in info:
                for key in info.variables:
                    if 'default' in info.variables[key]:
                        var def_value = info.variables[key]['default']
                        if not ProjectSettings.has_setting(key):
                            ProjectSettings.set_setting(key, def_value)
    update_plugin_list()

func _on_plugin_uninstall(package: String) -> void:
    if package in _PROJECT.packages:
        var local = _PROJECT.packages[package]
        if 'android_module' in local:
            remove_android_module(local.android_module)
        if 'autoload' in local:
            for key in local.autoload:
                ProjectSettings.set_setting('autoload/%s'%key, null)
    nativelib(['--uninstall', package])
    load_project()
    update_plugin_list()
    update_status()

func _on_plugin_update(package: String) -> void:
    nativelib(['--uninstall', package])
    nativelib(['--install', package])
    load_project()
    update_plugin_list()
    update_status()

func nativelib(params: Array, show_output: bool = true) -> Array:
    if _NL_GLOBAL:
        if OS.get_name() == 'Windows':
            params.push_front(_nativelib_path)
            return run_command(_python_path, params, show_output)
        else:
            return run_command(_nativelib_path, params, show_output)
    else:
        params.push_front(_local_nativelib)
        return run_command(_python_path, params, show_output)

func run_command(cmd: String, params: Array, show_output: bool = true) -> Array:
    #print('%s %s'%[cmd, params])
    var output := []
    var exit_code = OS.execute(cmd, params, true, output, true)
    if exit_code != 0:
        push_error('Command %s, exit code %d'%[cmd, exit_code])
    if show_output or exit_code != 0:
        for line in output:
            print(line)
    return output

func _on_InstallSystemButton_pressed() -> void:
    install_local_nativelib()
    yield(self, 'downloading_complete')
    check_system()

func _on_UpdateSystemButton_pressed() -> void:
    install_local_nativelib()
    yield(self, 'downloading_complete')
    check_system()

func _on_AndroidButton_toggled(button_pressed: bool) -> void:
    nativelib(['--android'], false)
    load_project()
    update_project_info()

func _on_iOSButton_toggled(button_pressed: bool) -> void:
    nativelib(['--ios'], false)
    load_project()
    update_project_info()

func remove_android_module(module: String) -> void:
    var modules := []
    if ProjectSettings.has_setting('android/modules'):
        var ms = ProjectSettings.get_setting('android/modules')
        if ms != null and ms != '':
            modules = ms.split(',')
    if module in modules:
        modules.erase(module)
        ProjectSettings.set_setting('android/modules', PoolStringArray(modules).join(','))

func add_android_module(module: String) -> void:
    var modules := []
    if ProjectSettings.has_setting('android/modules'):
        var ms = ProjectSettings.get_setting('android/modules')
        if ms != null and ms != '':
            modules = ms.split(',')
    if not module in modules:
        modules.append(module)
        ProjectSettings.set_setting('android/modules', PoolStringArray(modules).join(','))

func _on_FilterUniversal_toggled(button_pressed: bool) -> void:
    if button_pressed:
        if not 'all' in _platform_filter:
            _platform_filter.append('all')
            update_plugin_list()
    else:
        if 'all' in _platform_filter:
            _platform_filter.erase('all')
            update_plugin_list()

func _on_FilterAndroid_toggled(button_pressed: bool) -> void:
    if button_pressed:
        if not 'android' in _platform_filter:
            _platform_filter.append('android')
            update_plugin_list()
    else:
        if 'android' in _platform_filter:
            _platform_filter.erase('android')
            update_plugin_list()

func _on_FilterIOS_toggled(button_pressed: bool) -> void:
    if button_pressed:
        if not 'ios' in _platform_filter:
            _platform_filter.append('ios')
            update_plugin_list()
    else:
        if 'ios' in _platform_filter:
            _platform_filter.erase('ios')
            update_plugin_list()

func _on_SearchLineEdit_text_changed(new_text: String) -> void:
    _name_filter = new_text
    update_plugin_list()

func _on_SelectPythonButton_pressed() -> void:
    $PythonDialog.popup_centered()

func _on_PythonDialog_file_selected(path: String) -> void:
    _python_path = path
    ProjectSettings.set_setting('NativeLib/Python', _python_path)
    check_system()
