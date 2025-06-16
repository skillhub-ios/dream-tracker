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

    var buttonState: DButtonState {
        switch self {
        case .loading: return .loading
        case .success: return .normal
        case .error: return .normal
        }
    }
}

