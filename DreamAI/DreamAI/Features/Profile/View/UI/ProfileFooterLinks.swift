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
                Text("privacyPolicy")
            }
            Button(action: {
                openURL(Constants.termsURL)
            }) {
                Text("terms")
            }
            Button(action: {
                showDeleteAlert = true
            }) {
                Text("dataDeletion")
            }
        }
        .buttonStyle(UnderlineButtonStyle())
        .frame(maxWidth: .infinity, alignment: .center)
        .alert("deleteAll",
               isPresented: $showDeleteAlert
        ) {
            Button("cancel", role: .cancel) {
                showDeleteAlert = false
            }
            
            Button("delete", role: .destructive) {
                DIContainer.appDataResetManager.resetAll()
                showDeleteAlert = false
            }
        } message: {
            Text("permanentlyDeleteAlert")
        }
    }
}

#Preview {
    Section {
        ProfileFooterLinks()
    }
    .listRowBackground(Color.appGray4)
}
