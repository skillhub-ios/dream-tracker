//
//  ContentStateType.swift
//  DreamAI
//
//  Created by Shaxzod on 15/06/25.
//

import Foundation

enum ContentStateType {
    case loading
    case success
    case error(Error)
}

extension ContentStateType: Equatable {
    static func == (lhs: ContentStateType, rhs: ContentStateType) -> Bool {
        switch (lhs, rhs) {
        case (.loading, .loading): return true
        case (.success, .success): return true
        case (.error(let lhsError), .error(let rhsError)): return lhsError.localizedDescription == rhsError.localizedDescription
        default: return false
        }
    }
}
