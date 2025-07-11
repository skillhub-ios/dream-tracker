//
//  ProfileFooterLinks.swift
//  DreamAI
//
//  Created by Shaxzod on 19/04/25
//

import SwiftUI

struct ProfileFooterLinks: View {
    
    @Environment(\.openURL) private var openURL
    @State private var showDeleteAlert: Bool = false
    
    var body: some View {
        HStack(spacing: 16) {
            Button(action: {
                openURL(Constants.privacyPolicyURL)
            }) {
                Text("Privacy Policy")
            }
            Button(action: {
                openURL(Constants.termsURL)
            }) {
                Text("Terms")
            }
            Button(action: {
                showDeleteAlert = true
            }) {
                Text("Data Deletion")
            }
        }
        .buttonStyle(UnderlineButtonStyle())
        .frame(maxWidth: .infinity, alignment: .center)
        .alert("Delete All Data?",
               isPresented: $showDeleteAlert
        ) {
            Button("Cancel", role: .cancel) {
                showDeleteAlert = false
            }
            
            Button("Delete", role: .destructive) {
                DIContainer.appDataResetManager.resetAll()
                showDeleteAlert = false
            }
        } message: {
            Text("This action will permanently delete all data and cannot be undone.")
        }
    }
}

#Preview {
    Section {
        ProfileFooterLinks()
    }
    .listRowBackground(Color.appGray4)
}
