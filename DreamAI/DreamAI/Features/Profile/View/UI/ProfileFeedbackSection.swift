//
//  ProfileFeedbackSection.swift
//  DreamAI
//
//  Created by Shaxzod on 19/04/25
//

import SwiftUI

struct ProfileFeedbackSection: View {
    @EnvironmentObject var viewModel: ProfileViewModel
    @State private var language: String = "English"
    @State private var areNotificationsEnabled: Bool = true
    @State private var bedtime: Date = Date()
    @State private var wakeupTime: Date = Date()
    @Environment(\.openURL) private var openURL
    @Environment(\.languageManager) private var languageManager

    var body: some View {
        Section {
            HStack {
                Image(systemName: "globe")
                    .foregroundColor(.appPurple)
                Text("Language")
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
            
            Toggle(isOn: $areNotificationsEnabled) {
                HStack {
                    Image(systemName: "bell.fill")
                        .foregroundColor(.appPurple)
                    Text("Notifications")
                }
            }
            .tint(.appPurple)
            
            if areNotificationsEnabled {
                HStack {
                    Text("Bedtime")
                    Spacer()
                    DatePicker("", selection: $bedtime, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                        .foregroundColor(.appPurple)
                        .tint(.appPurple)
                }
                
                HStack {
                    Text("Wake-up")
                    Spacer()
                    DatePicker("", selection: $wakeupTime, displayedComponents: .hourAndMinute)
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
                    Text("Write feedback")
                    .foregroundColor(.white)

                    Spacer()

                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
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
