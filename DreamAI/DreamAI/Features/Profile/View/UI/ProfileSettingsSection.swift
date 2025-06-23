//
//  ProfileSettingsSection.swift
//  DreamAI
//
//  Created by Shaxzod on 19/04/25
//

import SwiftUI
import UserNotifications

struct ProfileSettingsSection: View {
    @EnvironmentObject var viewModel: ProfileViewModel
    @StateObject private var pushNotificationManager = PushNotificationManager.shared
    let exportImportAction: () -> Void
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    private var iCloudBinding: Binding<Bool> {
        Binding<Bool>(
            get: { viewModel.isICloudEnabled },
            set: { viewModel.userTogglediCloud(to: $0) }
        )
    }
    
    private var notificationBinding: Binding<Bool> {
        Binding<Bool>(
            get: { pushNotificationManager.authorizationStatus == .authorized },
            set: { handleNotificationToggle($0) }
        )
    }
    
    var body: some View {
        Section {
            iCloudRow(toggle: iCloudBinding)
                .frame(height: 40)
            notificationRow()
                .frame(height: 40)
            exportImportRow(action: exportImportAction)
                .frame(height: 40)
        }
        .alert("iCloud Sync", isPresented: $viewModel.showiCloudSignInAlert) {
            Button("Sign In") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("Cancel", role: .cancel) {
                viewModel.isICloudEnabled = false
            }
        } message: {
            Text("To enable sync, you need to sign in to your Apple account")
        }
        .alert("iCloud Status", isPresented: $viewModel.showiCloudStatusAlert) {
            Button("OK", role: .cancel) {
                viewModel.resetSyncStatusAlert()
            }
        } message: {
            Text(viewModel.iCloudStatusMessage)
        }
        .alert("Notification Settings", isPresented: $showAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
        .disabled(!viewModel.isSubscribed)
        .applyIf(!viewModel.isSubscribed) {
            $0.mask(Color.black.opacity(0.5))
        }
    }
}

//MARK: - Private IU

private extension ProfileSettingsSection {
    
    func iCloudRow(toggle: Binding<Bool>) -> some View {
        HStack {
            Image(systemName: "checkmark.icloud.fill")
                .font(.title3)
                .foregroundStyle(Color.appPurple)
            Text("iCloud")
            Spacer()
            if viewModel.isSubscribed {
                Toggle("", isOn: toggle)
                .tint(.appPurple)
            } else {
                Image(systemName: "lock.fill")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    func notificationRow() -> some View {
        HStack {
            Image(systemName: "bell.fill")
                .font(.title3)
                .foregroundStyle(Color.appPurple)
            VStack(alignment: .leading, spacing: 2) {
                Text("Notifications")
                if pushNotificationManager.isRegistered, let deviceToken = pushNotificationManager.deviceToken {
                    Text("Token: \(String(deviceToken.prefix(20)))...")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            Spacer()
            if viewModel.isSubscribed {
                Toggle("", isOn: notificationBinding)
                    .tint(.appPurple)
            } else {
                Image(systemName: "lock.fill")
                    .font(.title3)
                    .tint(.secondary)
            }
        }
        .onTapGesture {
            if viewModel.isSubscribed && pushNotificationManager.isRegistered {
                // Copy device token to clipboard
                if let deviceToken = pushNotificationManager.deviceToken {
                    UIPasteboard.general.string = deviceToken
                    alertMessage = "Device token copied to clipboard"
                    showAlert = true
                }
            }
        }
    }
    
    func exportImportRow(action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: "square.and.arrow.down")
                    .font(.title3)
                    .foregroundStyle(Color.appPurple)
                Text("Export/Import")
                    .foregroundStyle(.white)
                Spacer()
                if viewModel.isSubscribed {
                    Image(systemName: "chevron.right")
                        .font(.callout)
                        .foregroundColor(.secondary)
                } else {
                    Image(systemName: "lock.fill")
                        .font(.title3)
                        .tint(.secondary)
                }
            }
        }
    }
    
    private func handleNotificationToggle(_ enabled: Bool) {
        Task {
            if enabled {
                await pushNotificationManager.requestPermissions()
            } else {
                // Note: We can't programmatically disable notifications
                // Users need to do this in Settings
                alertMessage = "To disable notifications, please go to Settings > DreamAI > Notifications"
                showAlert = true
            }
        }
    }
}
#Preview {
    List {
        ProfileSettingsSection(exportImportAction: {})
            .environmentObject(ProfileViewModel())
    }
}

//MARK: - applyIf

extension View {
    @ViewBuilder
    func applyIf<T: View>(_ condition: Bool, apply: (Self) -> T) -> some View {
        if condition {
            apply(self)
        } else {
            self
        }
    }
}
