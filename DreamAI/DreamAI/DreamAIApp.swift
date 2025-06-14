//
//  DreamAIApp.swift
//  DreamAI
//
//  Created by Shaxzod on 07/06/25.
//

import SwiftUI

@main
struct DreamAIApp: App {
    var body: some Scene {
        WindowGroup {
            CreateDreamView()
            .colorScheme(.dark)
//            PermissionContainerView()
        }
    }
}
