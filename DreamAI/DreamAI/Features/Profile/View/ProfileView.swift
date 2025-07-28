//
//  ProfileView.swift
//  DreamAI
//
//  Created by Shaxzod on 19/04/25
//

import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @EnvironmentObject private var subscriptionViewModel: SubscriptionViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showExportImport = false
    @State private var isSigningOut = false
    
    // Access AuthManager
    private let authManager = AuthManager.shared

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appGray4
                    .ignoresSafeArea()
                    List {
                        ProfileSubscriptionSection()
                        ProfileSettingsSection(exportImportAction: {
                            showExportImport = true
                        })
                        ProfileFeedbackSection()
                        ProfileExitButton {
                            Task {
                               try await authManager.signOut()
                            }
                            withAnimation {
                                subscriptionViewModel.onboardingComplete = false
                            }
                        }
                        ProfileFooterLinks()
                            .listRowBackground(Color.appGray4)
                    }
                    .listSectionSpacing(12)
                    .environmentObject(viewModel)
                    .disabled(isSigningOut)
                
            }
            .navigationTitle("profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("cancel") {
                        dismiss()
                    }
                    .tint(.appPurple)
                    .disabled(isSigningOut)
                }
            }
            .sheet(isPresented: $showExportImport) {
                NavigationStack {
                    ExportImportView()
                }
            }
            .overlay {
                if isSigningOut {
                    MagicLoadingUI()
                        .frame(width: 40, height: 40)
                }
            }
        }
        .logScreenView(ScreenName.profile)
    }
    
    // MARK: - Sign Out Logic
    private func signOut() async {
        await MainActor.run {
            isSigningOut = true
        }
        
        do {
            try await authManager.signOut()
            await MainActor.run {
                isSigningOut = false
                dismiss()
            }
        } catch {
            await MainActor.run {
                isSigningOut = false
                // You might want to show an error alert here
                print("Sign out failed: \(error.localizedDescription)")
            }
        }
    }
}

#Preview {
    ZStack {
        Text("profile")
    }
    .sheet(isPresented: .constant(true)) {
        ProfileView()
            .environmentObject(SubscriptionViewModel())
            .environmentObject(OnboardingFlowViewModel())
    }
}
