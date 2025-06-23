//
//  ProfileHeaderView.swift
//  DreamAI
//
//  Created by Shaxzod on 19/04/25
//

import SwiftUI

struct ProfileHeaderView: View {
    var isPremium: Bool
    var body: some View {
        HStack {
            Button("Cancel") {
                // Dismiss action
            }
            .foregroundColor(Color.purple)
            Spacer()
            Text("Profile")
                .font(.headline)
                .foregroundColor(.primary)
            Spacer()
            // Placeholder for alignment
            Text("")
                .frame(width: 60)
                .opacity(0)
        }
        .padding(.top, 8)
        .padding(.bottom, 8)
        // Tab indicator (if needed)
        Rectangle()
            .frame(height: 2)
            .foregroundColor(Color.purple.opacity(0.3))
            .cornerRadius(1)
            .padding(.horizontal, 60)
    }
}

#Preview {
    ProfileHeaderView(isPremium: true)
} 