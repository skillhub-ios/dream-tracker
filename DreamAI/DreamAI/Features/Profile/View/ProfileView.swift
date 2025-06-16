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
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {

                        // Subscription Section
                        ProfileSubscriptionSection(isPremium: viewModel.isSubscribed, plan: viewModel.subscriptionPlan, expiry: viewModel.subscriptionExpiry)
                            .padding(.bottom, 16)
                        
                        // Settings Section
                        ProfileSettingsSection(viewModel: viewModel)
                            .padding(.bottom, 16)
                        
                        // Feedback
                        ProfileFeedbackSection()
                            .padding(.bottom, 16)
                        
                        // Exit Button
                        ProfileExitButton()
                            .padding(.bottom, 16)
                        
                        // Footer
                        ProfileFooterLinks()
                            .padding(.bottom, 8)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                }
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
