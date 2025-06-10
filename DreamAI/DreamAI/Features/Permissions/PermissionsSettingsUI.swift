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
                    Text(viewModel.selectedLanguage?.title ?? "")
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
                LanguagePicker(selectedLanguage: $viewModel.selectedLanguage, showLanguagePicker: $showLanguagePicker)
                    .presentationDetents([.large])
            }
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
        }
        .presentationDetents([.large])
//        .background(Color.appGray4)
    }
}


#Preview {
     PermissionsSettingsUI()
}
