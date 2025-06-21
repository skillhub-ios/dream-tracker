//
//  ProfileView.swift
//  DreamAI
//
//  Created by Shaxzod on 19/04/25
//

import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appGray4
                    .ignoresSafeArea()
                
                    List {

                        // Subscription Section
                        ProfileSubscriptionSection(isPremium: viewModel.isSubscribed, plan: viewModel.subscriptionPlan, expiry: viewModel.subscriptionExpiry)
                        
                        // Settings Section
                        ProfileSettingsSection(exportImportAction: {})
                        
                        // Feedback
                        ProfileFeedbackSection()

                        // Exit Button
                        ProfileExitButton()
                        
                        // Footer
                        ProfileFooterLinks()
                            .listRowBackground(Color.appGray4)
                    }
                    .listSectionSpacing(12)
                    .environmentObject(viewModel)
                
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .tint(.appPurple)
                }
            }
        }
    }
}

#Preview {
    ZStack {
        Text("Profile")
    }
    .sheet(isPresented: .constant(true)) {
        ProfileView()
    }
}
