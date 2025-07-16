//
// StartChatView.swift
//
// Created by Cesare on 16.07.2025 on Earth.
// 


import SwiftUI

struct StartChatView: View {
    
    var action: (() -> Void)?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("wantToGoDeeper")
                .font(.headline)
                .foregroundColor(.appWhite)
                Button {
                    action?()
                } label: {
                    HStack(spacing: 24) {
                        Image(.magicCircled)
                        Text("chatWithAI")
                            .font(.headline.bold())
                            .foregroundStyle(.white)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .resizable()
                            .frame(width: 10, height: 16)
                            .foregroundStyle(Color.appGray9.opacity(0.3))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 18)
                    .background {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.appPurpleDarkBackground.opacity(0.75))
                            .shadow(color: .black.opacity(0.25), radius: 6, x: 0, y: 4)
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.appPurpleDarkStroke, lineWidth: 1)
                    }
                }
                .buttonStyle(SmoothPressButtonStyle())
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 18)
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.appPurpleDarkBackground)
        }
    }
}

#Preview {
    StartChatView()
}
