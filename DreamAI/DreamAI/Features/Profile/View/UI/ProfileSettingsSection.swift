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
    @EnvironmentObject private var subscriptionViewModel: SubscriptionViewModel
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
//            notificationRow()
//                .frame(height: 40)
            exportImportRow(action: exportImportAction)
                .frame(height: 40)
        }
        .alert("iCloudSync", isPresented: $viewModel.showiCloudSignInAlert) {
            Button("signIn") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("cancel", role: .cancel) {
                viewModel.isICloudEnabled = false
            }
        } message: {
            Text("enableToSync")
        }
        .alert("iCloudStatus", isPresented: $viewModel.showiCloudStatusAlert) {
            Button("OK", role: .cancel) {
                viewModel.resetSyncStatusAlert()
            }
        } message: {
            Text(viewModel.iCloudStatusMessage)
        }
        .alert("notificationSettings", isPresented: $showAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
        .disabled(!subscriptionViewModel.isSubscribed)
        .applyIf(!subscriptionViewModel.isSubscribed) {
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
            if subscriptionViewModel.isSubscribed {
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
            Text("notifications")
            Spacer()
            if subscriptionViewModel.isSubscribed {
                Toggle("", isOn: notificationBinding)
                    .tint(.appPurple)
            } else {
                Image(systemName: "lock.fill")
                    .font(.title3)
                    .tint(.secondary)
            }
        }
    }
    
    func exportImportRow(action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: "square.and.arrow.down")
                    .font(.title3)
                    .foregroundStyle(Color.appPurple)
                Text("export")
                    .foregroundStyle(.white)
                Spacer()
                if subscriptionViewModel.isSubscribed {
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
                pushNotificationManager.disableNotifications()
            }
        }
    }
}

#Preview {
    List {
        ProfileSettingsSection(exportImportAction: {})
            .environmentObject(ProfileViewModel())
            .environmentObject(SubscriptionViewModel())
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
