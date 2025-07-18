//
// LinearGradient.swift
//
// Created by Cesare on 16.07.2025 on Earth.
// 

import SwiftUI

extension LinearGradient {
    static var appPurpleHorizontal: LinearGradient {
        LinearGradient(
            colors: [.appPurpleGradient4, .appPurpleGradient3],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}
