//
//  Dream.swift
//  DreamAI
//
//  Created by Shaxzod on 11/06/25.
//

import SwiftUI
import Foundation
import CloudKit

enum RequestStatus: Equatable, Codable {
    case idle
    case loading(progress: Double)
    case success
    case error
}

extension RequestStatus {
    func toString() -> String {
        switch self {
        case .idle: return "pending"
        case .loading(let progress): return "loading:\(progress)"
        case .success: return "success"
        case .error: return "error"
        }
    }
    
    static func fromString(_ string: String) -> RequestStatus {
        if string.starts(with: "loading:") {
            let progressString = string.replacingOccurrences(of: "loading:", with: "")
            let progress = Double(progressString) ?? 0.0
            return .loading(progress: progress)
        }
        
        switch string {
        case "pending": return .idle
        case "success": return .success
        case "error": return .error
        default: return .idle
        }
    }
}

// MARK: - UserCredential Model
struct UserCredential: Identifiable, Equatable, Codable {
    var id: UUID = UUID()
    let dreamText: String
    let selectedMood: Mood?
    
    // MARK: - Coding Keys
    private enum CodingKeys: String, CodingKey {
        case id, dreamText, selectedMood
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        dreamText = try container.decode(String.self, forKey: .dreamText)
        selectedMood = try container.decodeIfPresent(Mood.self, forKey: .selectedMood)
    }
    
    // Custom encoding
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(dreamText, forKey: .dreamText)
        try container.encodeIfPresent(selectedMood, forKey: .selectedMood)
    }
    
    // Initializer
    init(dreamText: String, selectedMood: Mood?) {
        self.id = UUID()
        self.dreamText = dreamText
        self.selectedMood = selectedMood
    }
}

struct Dream: Identifiable, Equatable, Codable {
    var id: UUID = UUID()
    let emoji: String
    let emojiBackground: Color
    let title: String
    let tags: [Tags]
    let date: Date
    var requestStatus: RequestStatus = .idle
    var interpretation: DreamInterpretationFullModel? = nil
    var userCredential: UserCredential? = nil
    
    // MARK: - Coding Keys
    private enum CodingKeys: String, CodingKey {
        case id, emoji, emojiBackgroundHex, title, tags, date, requestStatus, interpretation, userCredential
    }
    
    // MARK: - Initializer from UserCredential to Dream
    init(userCredential: UserCredential) {
        self.id = UUID()
        self.emoji = (userCredential.selectedMood ?? .happy).emoji
        self.emojiBackground = .appPurple
        self.title = userCredential.dreamText
        self.tags = []
        self.date = Date()
        self.requestStatus = .idle
        self.interpretation = nil
        self.userCredential = userCredential
    }

    // MARK: - Custom Coding Implementation
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        emoji = try container.decode(String.self, forKey: .emoji)
        let hexString = try container.decode(String.self, forKey: .emojiBackgroundHex)
        emojiBackground = Color(hex: hexString)
        title = try container.decode(String.self, forKey: .title)
        tags = try container.decode([Tags].self, forKey: .tags)
        date = try container.decode(Date.self, forKey: .date)
        requestStatus = try container.decode(RequestStatus.self, forKey: .requestStatus)
        
        // Decode interpretation with error handling
        do {
            interpretation = try container.decodeIfPresent(DreamInterpretationFullModel.self, forKey: .interpretation)
            if interpretation != nil {
                print("✅ Successfully decoded interpretation for dream: \(title)")
            }
        } catch {
            print("❌ Failed to decode interpretation for dream '\(title)': \(error)")
            interpretation = nil
        }
        
        // Decode user credential with error handling
        do {
            userCredential = try container.decodeIfPresent(UserCredential.self, forKey: .userCredential)
            if userCredential != nil {
                print("✅ Successfully decoded user credential for dream: \(title)")
            }
        } catch {
            print("❌ Failed to decode user credential for dream '\(title)': \(error)")
            userCredential = nil
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(emoji, forKey: .emoji)
        
        // Convert Color to hex string for storage
        let hexString = emojiBackground.toHex()
        try container.encode(hexString, forKey: .emojiBackgroundHex)
        
        try container.encode(title, forKey: .title)
        try container.encode(tags, forKey: .tags)
        try container.encode(date, forKey: .date)
        try container.encode(requestStatus, forKey: .requestStatus)
        
        // Encode interpretation with error handling
        if let interpretation = interpretation {
            do {
                try container.encode(interpretation, forKey: .interpretation)
                print("✅ Successfully encoded interpretation for dream: \(title)")
            } catch {
                print("❌ Failed to encode interpretation for dream '\(title)': \(error)")
            }
        }
        
        // Encode user credential with error handling
        if let userCredential = userCredential {
            do {
                try container.encode(userCredential, forKey: .userCredential)
                print("✅ Successfully encoded user credential for dream: \(title)")
            } catch {
                print("❌ Failed to encode user credential for dream '\(title)': \(error)")
            }
        }
    }
    
    // MARK: - Initializer
    init(emoji: String, emojiBackground: Color, title: String, tags: [Tags], date: Date, requestStatus: RequestStatus = .idle, interpretation: DreamInterpretationFullModel? = nil, userCredential: UserCredential? = nil) {
        self.emoji = emoji
        self.emojiBackground = emojiBackground
        self.title = title
        self.tags = tags
        self.date = date
        self.requestStatus = requestStatus
        self.interpretation = interpretation
        self.userCredential = userCredential
    }
}

// MARK: - Color Extension for Hex Conversion
extension Color {
    func toHex() -> String {
        let components = self.cgColor?.components
        let r: CGFloat = components?[0] ?? 0.0
        let g: CGFloat = components?[1] ?? 0.0
        let b: CGFloat = components?[2] ?? 0.0
        
        let hexString = String.init(format: "#%02lX%02lX%02lX", lroundf(Float(r * 255)), lroundf(Float(g * 255)), lroundf(Float(b * 255)))
        return hexString
    }
}

// MARK: - CloudKit
extension Dream {
    init?(record: CKRecord) {
        guard let title = record["title"] as? String,
              let emoji = record["emoji"] as? String,
              let emojiBackgroundHex = record["emojiBackground"] as? String,
              let date = record["date"] as? Date,
              let tagsRaw = record["tags"] as? [String],
              let requestStatusString = record["requestStatus"] as? String else {
            return nil
        }
        
        let tags = tagsRaw.compactMap { Tags(rawValue: $0) }
        let requestStatus = RequestStatus.fromString(requestStatusString)
        
        // Decode interpretation data if available
        var interpretation: DreamInterpretationFullModel? = nil
        if let interpretationData = record["interpretation"] as? Data {
            do {
                interpretation = try JSONDecoder().decode(DreamInterpretationFullModel.self, from: interpretationData)
                print("✅ Successfully decoded interpretation from CloudKit for dream: \(title)")
            } catch {
                print("❌ Failed to decode interpretation data from CloudKit: \(error)")
            }
        }
        
        // Decode user credential data if available
        var userCredential: UserCredential? = nil
        if let userCredentialData = record["userCredential"] as? Data {
            do {
                userCredential = try JSONDecoder().decode(UserCredential.self, from: userCredentialData)
                print("✅ Successfully decoded user credential from CloudKit for dream: \(title)")
            } catch {
                print("❌ Failed to decode user credential data from CloudKit: \(error)")
            }
        }
        
        self.init(
            emoji: emoji,
            emojiBackground: Color(hex: emojiBackgroundHex),
            title: title,
            tags: tags,
            date: date,
            requestStatus: requestStatus,
            interpretation: interpretation,
            userCredential: userCredential
        )
    }
}
