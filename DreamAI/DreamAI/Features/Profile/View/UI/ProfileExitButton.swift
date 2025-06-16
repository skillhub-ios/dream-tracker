//
//  ProfileExitButton.swift
//  DreamAI
//
//  Created by Shaxzod on 19/04/25
//

import SwiftUI

struct ProfileExitButton: View {
    var body: some View {
        Button(action: {
            // TODO: Implement exit action
        }) {
            Text("Exit")
                .foregroundColor(.red)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
        }
    }
}

#Preview {
    ProfileExitButton()
} 