//
//  EmptyStateCardView.swift
//  DreamAI
//
//  Created by Shaxzod on 19/04/25
//

import SwiftUI

struct EmptyStateCardView: View {
    var action: () -> Void = {}
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                
                ZStack {
                    Circle()
                        .fill(Color(hex: "#523761"))
                        .frame(width: 48, height: 48)
                    Image(systemName: "plus")
                        .font(.system(size: 28))
                        .foregroundColor(Color.appPurple)
                }
                HStack {
                    Text("logDream")
                    Text("🌙")
                }
                .font(.headline)
                .foregroundColor(.white)
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 24))
                    .foregroundColor(Color.appPurple)
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 18).stroke(Color.appPurpleDarkStroke))
            .background(RoundedRectangle(cornerRadius: 18).fill(Color.appPurpleDarkBackground.opacity(0.75)))
        }
        .padding(.horizontal)
    }
}

#Preview {
    EmptyStateCardView()
        .padding(.horizontal)
}
