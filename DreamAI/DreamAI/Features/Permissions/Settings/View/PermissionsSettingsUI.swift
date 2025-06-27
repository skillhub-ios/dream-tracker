//
//  PermissionsSettingsUI.swift
//  DreamAI
//
//  Created by Shaxzod on 19/04/25
//

import SwiftUI
import UserNotifications

struct PermissionsSettingsUI: View {
    @StateObject private var viewModel = PermissionsSettingsViewModel()
    @StateObject private var pushNotificationManager = PushNotificationManager.shared
    @StateObject private var authManager = AuthManager.shared
    @State private var showBedtimePicker = false
    @State private var showWakeupPicker = false
    @State private var showLanguagePicker = false
    @State private var showMainView = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
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
                    authManager.markPermissionsCompleted()
                    showMainView = true
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 24)
            .navigationDestination(isPresented: $showMainView) {
                NavigationStack {
                    MainView()
                }   
            }
        }
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.large)
        .alert("Notification Settings", isPresented: $showAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
        .task {
            await checkNotificationStatus()
        }
    }
}

private extension PermissionsSettingsUI {
    var notificationsSection: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Reminders")
                    .foregroundColor(.white)
                Spacer()
                Toggle("", isOn: $viewModel.remindersEnabled)
                    .toggleStyle(SwitchToggleStyle(tint: .purple))
                    .labelsHidden()
                    .onChange(of: viewModel.remindersEnabled) { oldValue, newValue in
                        handleNotificationToggle(newValue)
                    }
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
                    .disabled(!viewModel.remindersEnabled)
                    .colorMultiply(viewModel.remindersEnabled ? .purple : .gray)
                    .opacity(viewModel.remindersEnabled ? 1 : 0.5)
                    .accentColor(.white)
                    .colorScheme(.dark)
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
                
            }
            .padding(.vertical, 8)
            
            // Device Token Display (for debugging)
            if pushNotificationManager.isRegistered, let deviceToken = pushNotificationManager.deviceToken {
                Divider()
                VStack(alignment: .leading, spacing: 4) {
                    Text("Device Token")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                    Text(deviceToken)
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.5))
                        .lineLimit(2)
                        .textSelection(.enabled)
                }
                .padding(.vertical, 8)
            }
        }
        .padding(12)
        .background(Color.appPurpleDark)
        .cornerRadius(14)
    }
    
    var privacySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Privacy")
                .font(.headline)
                .foregroundColor(.white)
            HStack {
                Text("Face ID")
                    .foregroundColor(.white)
                Spacer()
                Toggle("", isOn: Binding(
                    get: { viewModel.faceIDEnabled },
                    set: { viewModel.toggleFaceID($0) }
                ))
                    .toggleStyle(SwitchToggleStyle(tint: .purple))
                    .labelsHidden()
            }
            .padding(12)
            .background(Color.appPurpleDark)
            .cornerRadius(14)
        }
    }
    
    var languageSection: some View {
        Button(action: { showLanguagePicker = true }) {
            HStack(spacing: 12) {
                if let flag = viewModel.selectedLanguage?.flag {
                    Image(flag)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                }
                
                Text(viewModel.selectedLanguage?.title ?? "Language")
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
            LanguagePicker(selectedLanguage: $viewModel.selectedLanguage, showLanguagePicker: $showLanguagePicker)
                .presentationDetents([.large])
        }
    }
    
    private func checkNotificationStatus() async {
        let isEnabled = await pushNotificationManager.areNotificationsEnabled()
        await MainActor.run {
            viewModel.remindersEnabled = isEnabled
        }
    }
    
    private func handleNotificationToggle(_ enabled: Bool) {
        Task {
            if enabled {
                await pushNotificationManager.requestPermissions()
                await checkNotificationStatus()
            } else {
                // Note: We can't programmatically disable notifications
                // Users need to do this in Settings
                alertMessage = "To disable notifications, please go to Settings > DreamAI > Notifications"
                showAlert = true
                await MainActor.run {
                    viewModel.remindersEnabled = true // Reset the toggle
                }
            }
        }
    }
}

extension View {
    @ViewBuilder func changeTextColor(_ color: Color) -> some View {
        if UITraitCollection.current.userInterfaceStyle == .light {
            self.colorInvert().colorMultiply(color)
        } else {
            self.colorMultiply(color)
        }
    }
}

struct LanguagePicker: View {
    @Binding var selectedLanguage: Language?
    @Binding var showLanguagePicker: Bool
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.appGray4.ignoresSafeArea()
                
                VStack {
                    List(selection: $selectedLanguage) {
                        ForEach(Language.allCases, id: \.self) { language in
                            HStack(spacing: 9) {
                                
                                Image(systemName: selectedLanguage == language ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(selectedLanguage == language ? .purple : .gray.opacity(0.5))
                                    .font(.system(size: 24))
                                
                                Image(language.flag)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 24, height: 24)
                                    .padding(.leading, 3)
                                
                                Text(language.title)
                                    .font(.headline)
                                    .foregroundColor(.white)
                                Spacer()
                            }
                        }
                        .listRowBackground(Color.appGray3)
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("Language")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        showLanguagePicker = false
                    }) {
                        Text("Done")
                            .font(.headline)
                            .foregroundColor(.purple)
                    }
                }
            }
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(Color.appGray4, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
        .presentationDetents([.large])
        .background(Color.appGray4)
    }
}


#Preview {
    NavigationStack {
        PermissionsSettingsUI()
    }
    .colorScheme(.dark)
}
