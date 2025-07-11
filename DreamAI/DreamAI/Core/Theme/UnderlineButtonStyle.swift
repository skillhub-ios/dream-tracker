//
// UnderlineButtonStyle.swift
//
// Created by Cesare on 11.07.2025 on Earth.
// 


import SwiftUI

struct UnderlineButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.footnote)
            .foregroundColor(.secondary)
            .underline()
    }
}
