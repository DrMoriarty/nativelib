# Why NativeLib?

If you already used Godot you know about AssetLib. Anybody could make his own useful addon and submit it into official AssetLib library. Also anybody could find this addon and easy install it into his project. Sounds good? Not exactly.

The simplification of AssetLib has some disadvantages:

- What if your addon depends on some other addon? How user will satisfy this requirements? And what happened if user will update one addon and forget of another related to the first one?

- What if your addon has some files related to specific export platforms, for example iOS and Android? These files might be huge and user who develop Android only project won't be glad when noticed many iOS frameworks in his files.

- What if your addon requires some customization? Should you write your own editor or just hope that user will read documentation till the end?

So after some reflection we think that we should have:

- Dependencies management
- Addon separation for platform specific parts
- Uniform and easy way to set project specific parameters

Congratulations! All of this are NativeLib.
