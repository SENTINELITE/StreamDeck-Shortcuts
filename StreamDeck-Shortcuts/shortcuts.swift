//
//  shortcuts.swift
//  StreamDeck-Shortcuts
//
//  Created by Kirk Land on 2/7/23.
//

import Foundation
import Intents
import AppIntents
import StreamDeck

@available(macOS 13, *)
struct Shortcut: AppIntent {
//    init() {
//        print("Init Shortcut Est")
//    }
    
    static var title: LocalizedStringResource = "Update StreamDeck Key"
    static var description = IntentDescription("Updates the displayed text on the specified StreamDeck Key")
    
    @Parameter(title: "String To Display")
    var str: String
    
    @MainActor
    func perform() async throws -> some IntentResult {
//        SharedData.shared.animateBool()
        print("Should've toggled the Lobby ")
        StreamDeckPlugin.shared.instances.values.forEach {
            $0.setTitle(to: "\(str)", target: nil, state: nil)
        }
        return .result(value: 75)
//        TestAction.updateText()
    }
    
    static var parameterSummary: some ParameterSummary {
            Summary("Final Summary")
        }
}
