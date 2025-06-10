//
//  PermissionsSettingsUI.swift
//  DreamAI
//
//  Created by Shaxzod on 19/04/25
//

import SwiftUI

struct PermissionsSettingsUI: View {
    @StateObject private var viewModel = PermissionsSettingsViewModel()
    @State private var showBedtimePicker = false
    @State private var showWakeupPicker = false
    @State private var showLanguagePicker = true
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.appPurpleDark, Color.black]),
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()
            VStack(alignment: .leading, spacing: 28) {
                notificationsSection
                privacySection
                languageSection
                Spacer()
                DButton(title: "Done") {
                    // Handle done
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 24)
        }
    }
    
    private var notificationsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Notifications")
                .font(.headline)
                .foregroundColor(.white)
            VStack(spacing: 0) {
                HStack {
                    Text("Reminders")
                        .foregroundColor(.white)
                    Spacer()
                    Toggle("", isOn: $viewModel.remindersEnabled)
                        .toggleStyle(SwitchToggleStyle(tint: .purple))
                        .labelsHidden()
                }
                .padding(.vertical, 8)
                Divider()
                HStack {
                    Text("Bedtime")
                        .foregroundColor(.white)
                    Spacer()
                    DatePicker("Bedtime", selection: $viewModel.bedtime, displayedComponents: .hourAndMinute)
                        .datePickerStyle(.compact)
                        .labelsHidden()
                        .colorInvert()
                        .disabled(!viewModel.remindersEnabled)
                        .colorMultiply(viewModel.remindersEnabled ? .purple : .gray)
                        .opacity(viewModel.remindersEnabled ? 1 : 0.5)
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
                        .colorInvert()
                        .disabled(!viewModel.remindersEnabled)
                        .colorMultiply(viewModel.remindersEnabled ? .purple : .gray)
                        .opacity(viewModel.remindersEnabled ? 1 : 0.5)
                }
                .padding(.vertical, 8)
            }
            .padding(12)
            .background(Color.appPurpleDark)
            .cornerRadius(14)
        }
    }
    
    private var privacySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Privacy")
                .font(.headline)
                .foregroundColor(.white)
            HStack {
                Text("Face ID")
                    .foregroundColor(.white)
                Spacer()
                Toggle("", isOn: $viewModel.faceIDEnabled)
                    .toggleStyle(SwitchToggleStyle(tint: .purple))
                    .labelsHidden()
            }
            .padding(12)
            .background(Color.appPurpleDark)
            .cornerRadius(14)
        }
    }
    
    private var languageSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Language")
                .font(.headline)
                .foregroundColor(.white)
            Button(action: { showLanguagePicker = true }) {
                HStack {
                    Text(viewModel.selectedLanguage.flag)
                    Text("Language")
                        .foregroundColor(.white)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.white.opacity(0.5))
                }
                .padding(12)
                .background(Color.appPurpleDark)
                .cornerRadius(14)
            }
            .sheet(isPresented: $showLanguagePicker) {
                VStack(spacing: 0) {
                    Text("Select Language")
                        .font(.headline)
                        .padding()
                    ForEach(viewModel.allLanguages) { lang in
                        Button(action: {
                            viewModel.selectedLanguage = lang
                            showLanguagePicker = false
                        }) {
                            HStack {
                                Text(lang.flag)
                                Text(lang.rawValue)
                                    .foregroundColor(.primary)
                                Spacer()
                                if viewModel.selectedLanguage == lang {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.purple)
                                }
                            }
                            .padding()
                        }
                    }
                }
                .presentationDetents([.height(400)])
            }
        }
    }
}

#Preview {
    PermissionsSettingsUI()
} 
