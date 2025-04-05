//
//  OpenAIVoicesInterface.swift
//  StreamDeck-Shortcuts
//
//  Created by Kirk Land on 11/10/23.
//

import Foundation
import OSLog

let audioDir = NSHomeDirectory().appending(
    "/Library/Application Support/com.elgato.StreamDeck/Plugins/com.sentinelite.sds-2.sdPlugin/audio")

enum Voice: String, CaseIterable, Identifiable, Codable {
    case system
    case alloy
    case echo
    case fable
    case nova
    case onyx
    case shimmer
    case ash
    case ballad
    case coral
    case sage
    case verse
    
    var id: Voice { self }
}

func getTextToSpeechAsync(text: String, shortcutUUID: String, voice: Voice) async throws -> URL {
    let loggerOpenAI = Logger(subsystem: "subsystem", category: "openAI")
    
    // Create URL
    guard let url = URL(string: "https://api.openai.com/v1/audio/speech") else {
        throw URLError(.badURL)
    }
    
    // Create request
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    
    // Set headers
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("Bearer \(openAIToken)", forHTTPHeaderField: "Authorization")
    
    // Create JSON data and pass in body
    let jsonData = try JSONSerialization.data(withJSONObject: [
        "input": text,
        "model": "gpt-4o-mini-tts",
        "voice": voice.rawValue,
        "response_format": "aac",
        "speed": "1.0",
    ])
    request.httpBody = jsonData
    
    // Make the request
    let (data, response) = try await URLSession.shared.data(for: request)
    
    // Check response
    guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
        loggerOpenAI.error("Bad Server Response")
        throw URLError(.badServerResponse)
    }
    
    loggerOpenAI.log("Response: \(response)")
    loggerOpenAI.log("About to save file...")
    
    //    let audioDir = NSHomeDirectory().appending("/Library/Application Support/com.elgato.StreamDeck/Plugins/com.sentinelite.sds-2.sdPlugin/audio/Shortcuts")
    let fileName = "/Shortcuts/\(shortcutUUID)_\(voice.rawValue).aac"
    let audioFilePath = audioDir.appending(fileName)
    
    let fileUrl = URL(fileURLWithPath: audioFilePath)
    
    loggerOpenAI.log("about to write file to \(fileUrl.absoluteString)")
    do {
        try data.write(to: fileUrl)
        loggerOpenAI.log("File saved successfully to: \(fileUrl.path)")
    } catch {
        loggerOpenAI.error("File saving failed with error: \(error)")
        throw error
    }
    
    return fileUrl
}
