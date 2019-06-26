
`CodaSwitchProfile` is a small plugin optimizing the use of StreamDeck and Panic Coda.

# Description

`CodaSwitchProfile` is a plugin that switch StreamDeck profiles within the extension of the current edited file in Coda.

# Features

- based on the [Elgato AppleMail sample plugin](https://github.com/elgatosf/streamdeck-applemail)
- code written in Objective-C
- macOS only
- detects if Panic Coda is running


# Installation

__NOT READY TO WORK - YOU NEED TO RE-BUILD IT IN XCODE__


- Change the `DEVICE_TARGET_NAME` variable in 'MyStreamDeckPlugin.m' with the name of your streamdeck device.

- Change the plugin profils with you own.

- Adjust the function `SwithProfileFromExtension` with the extension/profil name in 'MyStreamDeckPlugin.m'.

- Modify the manifest.json to match with your profiles and device type.
see [Profile documentation](https://developer.elgato.com/documentation/stream-deck/sdk/manifest/#profiles)

- install plugin and plugin's profils. 


Because event drived profils have to be readonly (sad), you have to prepare the profil first on streamdeck app and include it in the plugin.

- On StreamDeck app, make a standard profil with all your own actions.
- Export the profil with the profil name corresponding to the coda file extension. 
- Save the profil in the plugin folder "com.corcules.CodaSwitchProfile.streamDeckPlugin".
- Reference the profil in the plugin manifest.json
- On StreamDeck app, delete the standard profil
- Relaunch StreamDeck and install the plugin's profils



# Source code

The Sources folder contains the source code of the plugin.

