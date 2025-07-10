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
                                await signOut()
                            }
                        }
                        ProfileFooterLinks()
                            .listRowBackground(Color.appGray4)
                    }
                    .listSectionSpacing(12)
                    .environmentObject(viewModel)
                    .disabled(isSigningOut)
                
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
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
        Text("Profile")
    }
    .sheet(isPresented: .constant(true)) {
        ProfileView()
    }
}
