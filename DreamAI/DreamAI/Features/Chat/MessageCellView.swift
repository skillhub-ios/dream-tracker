//
// MessageCellView.swift
//
// Created by Cesare on 16.07.2025 on Earth.
// 


import SwiftUI

struct MessageCellView: View {
    
    let text: String
    let isResponse: Bool
    
    var body: some View {
        Text(text)
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background {
                RoundedRectangle(cornerRadius: 20)
                    .foregroundStyle(isResponse
                                     ? LinearGradient(colors: [.appGray7, .appGray8], startPoint: .trailing, endPoint: .leading)
                                     : LinearGradient.appPurpleHorizontal)
            }
    }
}

#Preview {
    VStack(spacing: 20) {
        MessageCellView(text: String(localized: "chatFirstMessage"), isResponse: true)
        MessageCellView(text: String(localized: "chatFirstMessage"), isResponse: false)
    }
}
