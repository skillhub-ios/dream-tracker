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
}
