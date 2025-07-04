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

struct Dream: Identifiable, Equatable, Codable {
    var id: UUID = UUID()
    var emoji: String
    let emojiBackground: Color
    var title: String
    var description: String
    let tags: [Tags]
    var date: Date
    var requestStatus: RequestStatus = .idle
    
    mutating func updateEmoji(_ emoji: String?) {
        guard let emoji else { return }
        self.emoji = emoji
    }
    
    // MARK: - Coding Keys
    private enum CodingKeys: String, CodingKey {
        case id, emoji, emojiBackgroundHex, title, tags, date, requestStatus, dreamDescription
    }
    
    // MARK: - CoreData
    init(from entity: DreamEntity) {
        self.id = entity.id ?? UUID()
        self.emoji = entity.emoji ?? "?"
        self.emojiBackground = Color(hex: entity.emojiBackground ?? "#FFFFFF")
        self.title = entity.title ?? ""
        self.tags = entity.tags?.split(separator: ",").compactMap { Tags(rawValue: String($0)) } ?? []
        self.date = entity.date ?? Date()
        self.description = entity.dreamDescription ?? ""
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
        description = try container.decode(String.self, forKey: .dreamDescription)
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
    }
    
    // MARK: - Initializer
    init(emoji: String, emojiBackground: Color, title: String, tags: [Tags], date: Date, requestStatus: RequestStatus = .idle, description: String = "") {
        self.emoji = emoji
        self.emojiBackground = emojiBackground
        self.title = title
        self.tags = tags
        self.date = date
        self.requestStatus = requestStatus
        self.description = description
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

        self.init(
            emoji: emoji,
            emojiBackground: Color(hex: emojiBackgroundHex),
            title: title,
            tags: tags,
            date: date,
            requestStatus: requestStatus
        )
    }
}
