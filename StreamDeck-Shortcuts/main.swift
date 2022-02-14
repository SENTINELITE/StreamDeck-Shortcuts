import Foundation
import StreamDeck
import Sentry


//  🔷----------------------------------------------------- ----------------------------------------------------- ----------------
//  | This will generate the manifest, but for now, we're manually* handling this outside... TODO: Adopt the manifest generation |
//  ----------------------------------------------------- ----------------------------------------------------- ------------------

let manifest = PluginManifest(
    name: "StreamDeck Shortcuts",
    description: "Launch Shortcuts straight from your StreamDeck! Features an accessibility mode for vision impaired users.",
    author: "SENTINELITE",
    icon: "Icons/shortcut",
    version: "1.0.5",
    os: [
        .mac(minimumVersion: "12.0")
    ],
    software: .minimumVersion("5.0"),
    sdkVersion: 2,
    codePath: "StreamDeck-Shortcuts",
    actions: [
        PluginAction(
            name: "Launch Shortcut",
            uuid: "shortcut.run",
            icon: "Icons/plus",
            states: [
                PluginActionState(image: "Icons/plus")
            ],
            tooltip: "Launches Shortcut!"),
    ])


//  🔷--------------------
//  | Starts the plugin. |
//  ----------------------

initalizeTD() //Starts TD...

//The initial signal won't send if the program exits too fast.
SentrySDK.start { options in
    options.dsn  = "https://e5b7ab3d23b04542818cc7bbd4a9dc0a@o1114114.ingest.sentry.io/6145162"
    options.debug = false // Enabled debug when first installing is always helpful
    options.tracesSampleRate = 0.1
//    options.
    options.enableSwizzling = false
}

processShortcuts()
PluginManager.main(plugin: ShortcutsPlugin.self, manifest: manifest)
