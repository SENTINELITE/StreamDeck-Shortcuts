import Foundation
import StreamDeck


//  🔷----------------------------------------------------- ----------------------------------------------------- ----------------
//  | This will generate the manifest, but for now, we're manually* handling this outside... TODO: Adopt the manifest generation |
//  ----------------------------------------------------- ----------------------------------------------------- ------------------

let manifest = PluginManifest(
    name: "StreamDeck Shortcuts",
    description: "Launch Shortcuts straight from your StreamDeck! Features an accessibility mode for vision impaired users.",
    author: "SENTINELITE",
    icon: "Icons/shortcut",
    version: "1.0",
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
PluginManager.main(plugin: CounterPlugin.self, manifest: manifest)

//Task {
//    async let xxvd =  RunShortcut(shortcutName: "Test's Delete")
//}
//["-e", "do shell script \"shortcuts run Test\'s\\\\ Delete\""]
//sleep(5)
//print("ea")
