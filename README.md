# NativeLib UI

NativeLib is a plugin management system for [Godot engine](http://godotengine.org/). It designed to easy operate with native libraries for iOS/Android. Also it takes care about plugin dependencies and provides hasslefree native libs updating.

## Installation

This repository contains project addon with GUI for command line NativeLib. Just copy it into your `addons` folder of your project and enable it in **Project > Project Settings > Plugins**.

Or you can install NativeLib from AssetLib [https://godotengine.org/asset-library/asset/824](https://godotengine.org/asset-library/asset/824)

## Platform notes

### Windows

You should install [Python 3](https://www.python.org/downloads/windows/). Than you should open NativeLib addon and select your python executable (button "Select Python" in right top corner). After that you will be able to use NativeLib.

### MacOS

Usually MacOSes have preinstalled python 2.7.x. NativeLib-CLI tested with this python version and it should work. But if you have some strange errors you can try install Python 3. With it NativeLib works more stable.

### Linux

Install python 3 (if it's not installed yet). Also check if python is available in your $PATH. You can set path to python executable if necessary (button "Select Python" in right top corner).

### Python notes

Unfortunately I can not test NativeLib with every version of Python (at least I know that NativeLib doesn't work with python 3.5.x)

Usually I check it with python 2.7.x and 3.9.x. If you have strange errors try to upgrade your Python version. 

## First launch

During first launch it will install local copy of NativeLib (if you don't have one at system level) and it will update local repository so you can instantly start working with plugins.

## Settings

In the bottom status line there are very useful command buttons. Enable Android platform (button with robot) or iOS platform (button with apple) before installing any plugin. Also you can install local or update local NativeLib at any time. The last button updates local repository and fetches info about new plugins.

# TODO
* Ability to show files of installed plugin
* Show files which differs from the original ones.
