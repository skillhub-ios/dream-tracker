//
//  PermissionContainerView.swift
//  DreamAI
//
//  Created by Shaxzod on 07/06/25.
//

import SwiftUI

struct PermissionContainerView: View {
    @State private var currentStep: Int = 0
    @State private var showSettings = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    gradient: Gradient(
                        colors: [
                            Color(.sRGB, red: 38/255, green: 18/255, blue: 44/255, opacity: 1),
                            Color.black
                        ]
                    ),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    paginationIndicator
                    TabView(selection: $currentStep) {
                        PermissionsFeelingsUI()
                            .tag(0)
                        PermissionsLifeFocusUI()
                            .tag(1)
                        PermissionsPersonalizationUI()
                            .tag(2)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .indexViewStyle(.page(backgroundDisplayMode: .never))
                    .frame(maxHeight: .infinity, alignment: .top)
                    .onChange(of: currentStep) { oldValue, newValue in
                        print("Current step: \(newValue)")
                    }
                    
                    Spacer()
                    nextButton
                        .padding(.horizontal, 16)
                    skipButton
                }
            }
            .toolbarVisibility(.hidden, for: .navigationBar)
            .fullScreenCover(isPresented: $showSettings) {
                NavigationStack {
//                    PermissionsSettingsUI()
                }
            }
            .logScreenView(ScreenName.onboarding)
        }
    }
}

// MARK: - Private UI

private extension PermissionContainerView {
    
    var paginationIndicator: some View {
        HStack(spacing: 8) {
            ForEach(0..<3) { idx in
                Capsule()
                    .frame(width: 28, height: 5)
                    .foregroundColor(idx == currentStep ? Color.appPurple : Color.white.opacity(0.18))
            }
        }
        .padding(.top, 20)
    }
    
    var nextButton: some View {
        DButton(title: "Next") {
            if currentStep < 2 {
                withAnimation {
                    currentStep += 1
                }
            } else {
                showSettings = true
            }
        }
        .padding(.bottom, 4)
    }
    
    var skipButton: some View {
        Button(action: {
            showSettings = true
        }) {
            Text("Skip")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
        }
    }
}

#Preview {
    PermissionContainerView()
}
