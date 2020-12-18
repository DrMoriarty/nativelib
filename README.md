# NativeLib UI

NativeLib is a plugin management system for [Godot engine](http://godotengine.org/). It designed to easy operate with native libraries for iOS/Android. Also it takes care about plugin dependencies and provides hasslefree native libs updating.

This repository contains project addon with GUI for command line NativeLib. Just copy it into your `addons` folder of your project and enable it.

During first launch it will install local copy of NativeLib (if you don't have one at system level) and it will update local repository so you can instantly start working with plugins.

In the bottom status line there are very useful command buttons. Enable Android platform (button with robot) or iOS platform (button with apple) before installing any plugin. Also you can install local or update local NativeLib at any time. The last button updates local repository and fetches info about new plugins.

# TODO
* Search plugins
* Show dependencies in UI
* Ability to show files of installed plugin
* Show files which differs from the original ones.
