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
    @State private var isUpdatingNotificationStatus = false
    
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
            // Initial status will be set by the ViewModel
        }
        .onChange(of: pushNotificationManager.authorizationStatus) { oldValue, newValue in
            Task {
                await MainActor.run {
                    isUpdatingNotificationStatus = true
                    viewModel.remindersEnabled = (newValue == .authorized)
                    isUpdatingNotificationStatus = false
                }
            }
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
                        // Only handle user-initiated changes, not programmatic updates
                        if !isUpdatingNotificationStatus {
                            handleNotificationToggle(newValue)
                        }
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
