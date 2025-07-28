//
// PermissionSettingsView.swift
//
// Created by Cesare on 23.07.2025 on Earth.
//


import SwiftUI

struct PermissionSettingsView: View {
    
    @EnvironmentObject private var pushNotificationManager: PushNotificationManager
    
    private var notificationBinding: Binding<Bool> {
        Binding<Bool>(
            get: { pushNotificationManager.isRegistered },
            set: { handleNotificationToggle($0) }
        )
    }
    
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
                    Toggle("", isOn: notificationBinding)
                        .toggleStyle(SwitchToggleStyle(tint: .purple))
                        .labelsHidden()
                        .disabled(pushNotificationManager.authorizationStatus == .denied)
                        .opacity(pushNotificationManager.authorizationStatus == .denied ? 0.5 : 1.0)
                }
                .padding(.vertical, 8)
                
                // Показываем время только если нотификации включены
                if pushNotificationManager.isRegistered {
                    Divider()
                    HStack {
                        Text("bedtime")
                            .foregroundColor(.white)
                        Spacer()
                        DatePicker("bedtime", selection: Binding(
                            get: { pushNotificationManager.bedtime },
                            set: { pushNotificationManager.bedtime = $0; scheduleNotifications() }
                        ), displayedComponents: .hourAndMinute)
                            .datePickerStyle(.compact)
                            .labelsHidden()
                            .colorMultiply(.purple)
                            .accentColor(.white)
                            .colorScheme(.dark)
                    }
                    .padding(.vertical, 8)
                    Divider()
                    HStack {
                        Text("Wake-up")
                            .foregroundColor(.white)
                        Spacer()
                        DatePicker("Wake-up", selection: Binding(
                            get: { pushNotificationManager.wakeup },
                            set: { pushNotificationManager.wakeup = $0; scheduleNotifications() }
                        ), displayedComponents: .hourAndMinute)
                            .datePickerStyle(.compact)
                            .labelsHidden()
                            .colorMultiply(.purple)
                            .accentColor(.white)
                            .colorScheme(.dark)
                    }
                    .padding(.vertical, 8)
                }
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
                // Если разрешение не получено, запрашиваем его
                if pushNotificationManager.authorizationStatus != .authorized {
                    await pushNotificationManager.requestPermissions()
                }
                
                // Если разрешение получено, включаем нотификации
                if pushNotificationManager.authorizationStatus == .authorized {
                    await pushNotificationManager.scheduleDreamReminders(
                        bedtime: pushNotificationManager.bedtime,
                        wakeup: pushNotificationManager.wakeup
                    )
                }
            } else {
                pushNotificationManager.disableNotifications()
            }
        }
    }
    
    private func scheduleNotifications() {
        Task {
            if pushNotificationManager.isRegistered {
                await pushNotificationManager.scheduleDreamReminders(
                    bedtime: pushNotificationManager.bedtime,
                    wakeup: pushNotificationManager.wakeup
                )
            }
        }
    }
}

#Preview {
    PermissionSettingsView()
        .padding()
        .environmentObject(BiometricManagerNew())
        .environmentObject(PushNotificationManager.shared)
}
