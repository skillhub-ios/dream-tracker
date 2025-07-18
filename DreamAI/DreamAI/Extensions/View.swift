//
// View.swift
//
// Created by Cesare on 10.07.2025 on Earth.
//


import SwiftUI

extension View {
    func logScreenView(_ name: String) -> some View {
        let analytics = DIContainer.analyticsManager
        return self.onAppear {
            analytics.log(.screenViewed(name: name))
        }
    }
    
    func messageAlignment(isResponse: Bool) -> some View {
        let alignment: Alignment = isResponse ? .leading : .trailing
        
        return self
            .frame(maxWidth: SCREEN_WIDTH * 0.75, alignment: alignment)
            .frame(maxWidth: .infinity, alignment: alignment)
    }
}
