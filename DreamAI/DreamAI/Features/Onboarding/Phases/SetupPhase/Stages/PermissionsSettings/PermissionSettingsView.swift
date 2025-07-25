//
// PermissionSettingsView.swift
//
// Created by Cesare on 23.07.2025 on Earth.
//


import SwiftUI

struct PermissionSettingsView: View {
    
    @EnvironmentObject private var pushNotificationManager: PushNotificationManager
    @StateObject private var viewModel = PermissionsSettingsViewModel()
    @State private var isUpdatingNotificationStatus = false
    
    var body: some View {
        VStack(spacing: 24) {
            notificationsSection
            biometricSection
        }
        .frame(maxWidth: .infinity, alignment: .top)
    }
}

private extension PermissionSettingsView {
    var notificationsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("notifications")
                .font(.title2.bold())
                .foregroundStyle(.white)
            VStack(spacing: 0) {
                HStack {
                    Text("Reminders")
                        .foregroundColor(.white)
                    Spacer()
                    Toggle("", isOn: $viewModel.remindersEnabled)
                        .toggleStyle(SwitchToggleStyle(tint: .purple))
                        .labelsHidden()
                        .onChange(of: viewModel.remindersEnabled) { oldValue, newValue in
                            // Only handle user-initiated changes, not programmatic updates
                            if !isUpdatingNotificationStatus {
                                handleNotificationToggle(newValue)
                            }
                        }
                }
                .padding(.vertical, 8)
                Divider()
                HStack {
                    Text("bedtime")
                        .foregroundColor(.white)
                    Spacer()
                    DatePicker("bedtime", selection: $viewModel.bedtime, displayedComponents: .hourAndMinute)
                        .datePickerStyle(.compact)
                        .labelsHidden()
                        .disabled(!viewModel.remindersEnabled)
                        .colorMultiply(viewModel.remindersEnabled ? .purple : .gray)
                        .opacity(viewModel.remindersEnabled ? 1 : 0.5)
                        .accentColor(.white)
                        .colorScheme(.dark)
                        .onChange(of: viewModel.bedtime) { oldValue, newValue in
                            if viewModel.remindersEnabled {
                                scheduleNotifications()
                            }
                        }
                }
                .padding(.vertical, 8)
                Divider()
                HStack {
                    Text("Wake-up")
                        .foregroundColor(.white)
                    Spacer()
                    DatePicker("Wake-up", selection: $viewModel.wakeup, displayedComponents: .hourAndMinute)
                        .datePickerStyle(.compact)
                        .labelsHidden()
                        .disabled(!viewModel.remindersEnabled)
                        .colorMultiply(viewModel.remindersEnabled ? .purple : .gray)
                        .opacity(viewModel.remindersEnabled ? 1 : 0.5)
                        .accentColor(.white)
                        .colorScheme(.dark)
                        .onChange(of: viewModel.wakeup) { oldValue, newValue in
                            if viewModel.remindersEnabled {
                                scheduleNotifications()
                            }
                        }
                }
                .padding(.vertical, 8)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(Color.appPurpleDark)
            .cornerRadius(14)
        }
    }
    
    
    var biometricSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Privacy")
                .font(.title2.bold())
                .foregroundStyle(.white)
            BiometricSettingsView()
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
                .background(Color.appPurpleDark)
                .cornerRadius(14)
        }
    }
    
    private func handleNotificationToggle(_ enabled: Bool) {
        Task {
            if enabled {
                await pushNotificationManager.requestPermissions()
                // Schedule notifications with current bedtime/wakeup times
                await pushNotificationManager.scheduleDreamReminders(
                    bedtime: viewModel.bedtime,
                    wakeup: viewModel.wakeup
                )
            } else {
                pushNotificationManager.disableNotifications()
            }
        }
    }
    
    private func scheduleNotifications() {
        Task {
            await pushNotificationManager.scheduleDreamReminders(
                bedtime: viewModel.bedtime,
                wakeup: viewModel.wakeup
            )
        }
    }
}

#Preview {
    PermissionSettingsView()
        .environmentObject(BiometricManagerNew())
        .environmentObject(PushNotificationManager.shared)
}
