//
// UnderlineWhiteStyle.swift
//
// Created by Cesare on 21.07.2025 on Earth.
// 


import SwiftUI

struct UnderlineWhiteStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.footnote.bold())
            .foregroundColor(.white)
            .underline()
    }
}
