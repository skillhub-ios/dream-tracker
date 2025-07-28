//
// DreamDateView.swift
//
// Created by Cesare on 02.07.2025 on Earth.
// 

import SwiftUI

struct DreamDateView: View {
    @Binding var date: Date
    var isCreating: Bool
    
    var body: some View {
        HStack(spacing: 8) {
            DatePicker(selection: $date) {
                Text(isCreating ? "describeDream" : "dreamDescription")
                    .font(.subheadline.bold())
                    .lineLimit(1)
                    .minimumScaleFactor(0.1)
                    .foregroundColor(.white)
            }
            .tint(Color.appPurple)
            .font(.headline)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.appGray1)
            .cornerRadius(12)
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        DreamDateView(date: .constant(.now), isCreating: false)
        DreamDateView(date: .constant(.now), isCreating: true)
    }
    .padding(.horizontal, 16)
}
