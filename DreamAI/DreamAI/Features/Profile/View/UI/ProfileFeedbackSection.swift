//
//  ProfileFeedbackSection.swift
//  DreamAI
//
//  Created by Shaxzod on 19/04/25
//

import SwiftUI

struct ProfileFeedbackSection: View {
    @EnvironmentObject var viewModel: ProfileViewModel
    @StateObject private var pushNotificationManager = PushNotificationManager.shared
    @Environment(\.openURL) private var openURL
    @Environment(\.languageManager) private var languageManager
    
    var notificationBinding: Binding<Bool> {
        Binding<Bool>(
            get: { pushNotificationManager.userWantsNotifications },
            set: { handleNotificationToggle($0) }
        )
    }
    
    var body: some View {
        Section {
            HStack {
                Image(systemName: "globe")
                    .foregroundColor(.appPurple)
                Text("language")
                Spacer()
                Text(languageManager.currentLanguageDisplayName)
                    .foregroundColor(.secondary)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                languageManager.openSystemLanguageSettings()
            }
            
            Toggle(isOn: Binding(
                get: { viewModel.isFaceIDEnabled },
                set: { viewModel.userToggledFaceID(to: $0) }
            )) {
                HStack {
                    Image(systemName: "faceid")
                        .foregroundColor(.appPurple)
                    Text("Face ID")
                }
            }
            .tint(.appPurple)
            
            Toggle(isOn: notificationBinding) {
                HStack {
                    Image(systemName: "bell.fill")
                        .foregroundColor(.appPurple)
                    Text("notifications")
                }
            }
            .tint(.appPurple)
            .disabled(pushNotificationManager.authorizationStatus == .denied)
            .opacity(pushNotificationManager.authorizationStatus == .denied ? 0.5 : 1.0)
            
            if pushNotificationManager.isRegistered {
                HStack {
                    Text("bedtime")
                    Spacer()
                    DatePicker("", selection: Binding(
                        get: { pushNotificationManager.bedtime },
                        set: { newValue in
                            pushNotificationManager.bedtime = newValue
                            scheduleNotifications()
                        }
                    ), displayedComponents: .hourAndMinute)
                        .labelsHidden()
                        .foregroundColor(.appPurple)
                        .tint(.appPurple)
                }
                
                HStack {
                    Text("wakeup")
                    Spacer()
                    DatePicker("", selection: Binding(
                        get: { pushNotificationManager.wakeup },
                        set: { newValue in
                            pushNotificationManager.wakeup = newValue
                            scheduleNotifications()
                        }
                    ), displayedComponents: .hourAndMinute)
                        .labelsHidden()
                        .foregroundColor(.appPurple)
                        .tint(.appPurple)
                }
            }
            
            Button(action: {
                openURL(Constants.feedbackMailboxURL)
            }) {
                HStack {
                    Image(systemName: "envelope.fill")
                        .foregroundColor(.appPurple)
                    Text("writeFeedback")
                    .foregroundColor(.white)

                    Spacer()

                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
            }
        }
    }
    
    private func handleNotificationToggle(_ enabled: Bool) {
        Task {
            if enabled {
                if pushNotificationManager.authorizationStatus != .authorized {
                    await pushNotificationManager.requestPermissions()
                }
                if pushNotificationManager.authorizationStatus == .authorized {
                    pushNotificationManager.userWantsNotifications = true
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
    List {
        ProfileFeedbackSection()
            .environmentObject(ProfileViewModel())
    }
}
