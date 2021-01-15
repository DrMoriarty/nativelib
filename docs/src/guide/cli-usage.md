# CLI Utility

## Installation

If you experienced user of Terminal and very comfortable with command line utilities you could prefer install NativeLib-CLI.

Just run this command:

```
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/DrMoriarty/nativelib-cli/HEAD/install.sh)"
```

This will install `nativelib` to your system. It may require sudo rights.

::: tip
If installer script fails in your system, you could just download copy of [nativelib](https://github.com/DrMoriarty/nativelib-cli) script and put it somewhere your $PATH will find it.
:::

## Usage

If you installed GUI Addon you might want to use always the same CLI utility version in order to prevent conflicts. Just remove file `res://addons/NativeLib/nativelib` and GUI Addon will use your system wide NativeLib utility.

With command line utility you can not only install and uninstall packages. You also can make your own packages and store them in local repository.

```
bash-3.2$ nativelib -h

Usage: nativelib [options] [command]

Repository related commands:
    -s|--search <pattern>	Search packages in repository
    -I|--info <package>		Show details about specific package
    -U|--update			Update repository info
    -P|--pack <path>		Pack the plugin in the specific path into local repository
    --publish <path>		Pack and publish plugin in the specific path into remote repository

Repository related options:
    -C|--no-cleanup		Don't remove temporary files

Project related commands:
    -i|--install <package>	Install package
    -u|--uninstall <package>	Uninstall package
    -l|--list			List installed packages
    -p|--prepare		Prepare project on new machine (install all required packages)

Project related options:
    --ios			Process iOS platform (also add iOS to project's platform list)
    --android			Process Android platform (also add Android to project's platform list)
    -o|--overwrite		Overwrite files during installation

Other commands:
    -h|--help			Prints this page
    --version			Prints NativeLib version

Other options:
    -f|--force			Ignore errors and warnings if possible
    -v|--verbose		More debug output
```

::: warning
When you use CLI utility Godot should be closed. Otherwise your `project.godot` file will be overwritten and changes will lost.
:::

## Local repository

When you first time update repository info NativeLib will create it's internal files in your home directory. The structure of local repository looks like this:

```
~/.nativelib
    meta
        package1
            package1_1.2.3_meta.json
        package2
            package2_3.2.1_meta.json
    packages
        package3
            1.2.3
                package3_1.2.3_android.tgz
                package3_1.2.3_ios.tgz
                package3_1.2.3_all.tgz
    projects
        42127b6c-476f-4cd8-af08-199291bf6d6f
            package1@1.2.3
```

The `meta` folder contains information about all available packages. In `packages` there are downloaded packages or packages which you build locally. `projects` has logs about all your installed packages. They will be used in case of update or uninstall package.
