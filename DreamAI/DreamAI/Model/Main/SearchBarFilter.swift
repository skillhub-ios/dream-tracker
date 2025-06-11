//
//  SearchBarFilter.swift
//  DreamAI
//
//  Created by Shaxzod on 11/06/25.
//
import Foundation

enum SearchBarFilter: String, CaseIterable, Equatable {
    case newestFirst = "Newest First"
    case oldestFirst = "Oldest First"
    case tags = "Tags"
    case moods = "Moods"
    
    var systemImage: String {
        switch self {
        case .newestFirst: return "arrow.up"
        case .oldestFirst: return "arrow.down"
        case .tags: return "a.circle"
        case .moods: return "face.smiling"
        }
    }
}
