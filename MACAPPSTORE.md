# Publication from Godot Engine to Mac AppStore

### 1) Download Apple Transporter (if not downloaded yet)

https://apps.apple.com/us/app/transporter/id1450874784?mt=12

### 2) Download Xcode (if not downloaded yet)

### 3) Create and download production certificates:

Start Xcode, than Preference - Accounts - Your AppleID

Select your team, than press Manage Certificates

Ensure that you have Apple Distribution and Mac Installer Distribution certificates, if not create them (with plus button)

### 4) Unless https://github.com/godotengine/godot/issues/49590 was fixed you should manually edit Info.plist of your export template.

Unpack `osx.zip` in folder `Library/Application Support/Godot/templates/<godot_version>` (this is the Library in your home directory, not the system one)

Then open file osx_template.app/Contents/Info.plist and add this two strings _before_ the last `</dict>`
```
<key>LSApplicationCategoryType</key>
<string>public.app-category.games</string>
```
Then you should pack `osx_template.app` again in ZIP archive and replace `osx.zip` with it.

### 5) Godot Export 

Add OSX export (if not added yet)

Codesign - Identity - paste your TeamID

(see your TeamID at https://developer.apple.com/account/#/membership/)

Check in App Sandbox - Enabled

Then export project, it will ask you for password, it is normal

during export should not appear any errors (especially about signing)

### 6) Open your DMG file which was created by Godot (double click on it)

You should have new mounted disk image.

### 7) Magic #1

open Terminal and run this command:
```
productbuild --component /Volumes/YourNewVolumeFromTheDMGFile/YourAppName.app /Applications unsigned.pkg
```

Where `YourNewVolumeFromTheDMGFile` is a folder with DMG file content,

`YourAppName.app` is the name of your game how it was called during export

You can use TAB key, so enter one or two first letters and press TAB. Then Terminal can append other symbols of file/folder name.

After this command you should get file unsigned.pkg (in your home directory, if you did’n change it)

### 8) Magic #2

Don’t close the Terminal, you should cast one more spell:
```
productsign --sign "3rd Party Mac Developer Installer: YourTeamName (YourTeamID)" unsigned.pkg signed.pkg
```
In the quotes there is your publisher certificate name. You can see it’s name in your Keychain app.

### 9) PROFIT

Run Transporter app and load the signed.pkg into it. Then press tree dots and select Validate.

If you get any errors then check steps before. If there are no errors then you could upload the build to AppStore!

## Troubleshooting

`ERROR ITMS-90237: "The product archive package's signature is invalid. Ensure that it is signed with your "3rd Party Mac Developer Installer" certificate."`

this means that you didn’t do signing step 8 (or it finished with error)

`ERROR ITMS-90242: "The product archive is invalid. The Info.plist must contain a LSApplicationCategoryType key, whose value is the UTI for a valid category. For more details, see "Submitting your Mac apps to the App Store".`

this means that you missed step 4.
