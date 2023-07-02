//
//  StreamDeck_Shortcuts_AppIntents.swift
//  StreamDeck-Shortcuts-AppIntents
//
//  Created by Kirk Land on 2/7/23.
//

import AppIntents

struct StreamDeck_Shortcuts_AppIntents: AppIntent {
    static var title: LocalizedStringResource = "StreamDeck-Shortcuts-AppIntents"
    
    func perform() async throws -> some IntentResult {
        return .result()
    }
}

struct Shortcut: AppIntent {
    
    static var title: LocalizedStringResource = "V2 Update StreamDeck Key"
    static var description = IntentDescription("V2 Updates the displayed text on the specified StreamDeck Key")
    
    @Parameter(title: "V2 String To Display")
    var str: String
    
    @MainActor
    func perform() async throws -> some IntentResult {
//        SharedData.shared.animateBool()
        print("V2 perform action")
//        StreamDeckPlugin.shared.instances.values.forEach {
//            $0.setTitle(to: "\(str)", target: nil, state: nil)
//        }
        return .result(value: 75)
//        TestAction.updateText()
    }
    
    static var parameterSummary: some ParameterSummary {
            Summary("V2 Final Summary")
        }
}


//

struct ConvertUnixTimeToDate: AppIntent, CustomIntentMigratedAppIntent {
    static let intentClassName = "UnixTimeToDateIntent"

    static let title: LocalizedStringResource = "V2 DEBUG - Convert Unix Time to Date"

    static let description = IntentDescription(
"""
Returns the date for the input Unix time.

Unix time (also known as Epoch time) is a system for describing a point in time — the number of seconds that have elapsed since the Unix epoch.
""",
        categoryName: "Date"
    )

    @Parameter(title: "Unix Time", description: "Example: 1663178163", controlStyle: .field)
    var unixTime: Int

    static var parameterSummary: some ParameterSummary {
        Summary("Convert \(\.$unixTime) to a date")
    }

    func perform() async throws -> some IntentResult & ReturnsValue<Date> {
        .result(value: Date(timeIntervalSince1970: Double(unixTime)))
    }
}

