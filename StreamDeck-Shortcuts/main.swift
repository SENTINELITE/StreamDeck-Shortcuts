import Foundation
import StreamDeck


//  🔷----------------------------------------------------- ----------------------------------------------------- ----------------
//  | This will generate the manifest, but for now, we're manually* handling this outside... TODO: Adopt the manifest generation |
//  ----------------------------------------------------- ----------------------------------------------------- ------------------

let manifest = PluginManifest(
    name: "YetAnotherTest",
    description: "Launch Shortcuts straight from your StreamDeck!",
    author: "SENTINELITE",
    icon: "counter",
    version: "0.5",
    os: [
        .mac(minimumVersion: "12.0")
    ],
    software: .minimumVersion("4.1"),
    sdkVersion: 2,
    codePath: "streamdeck-WS-Test",
    actions: [
        PluginAction(
            name: "addStuff",
            uuid: "yat.increment",
            icon: "Icons/plus",
            states: [
                PluginActionState(image: "Icons/plus")
            ],
            tooltip: "Increment the count."),
    ])


//  🔷--------------------
//  | Starts the plugin. |
//  ----------------------

initalizeTD() //Starts TD...
PluginManager.main(plugin: CounterPlugin.self, manifest: manifest)
