//
//  PermissionContainerView.swift
//  DreamAI
//
//  Created by Shaxzod on 07/06/25.
//

import SwiftUI

struct PermissionContainerView: View {
    @State private var currentStep: Int = 0
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color(.sRGB, red: 38/255, green: 18/255, blue: 44/255, opacity: 1), Color(.sRGB, red: 18/255, green: 18/255, blue: 28/255, opacity: 1)]),
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 24) {
                TabView(selection: $currentStep) {
                    PermissionsFeelingsUI()
                        .tag(0)
                    PermissionsLifeFocusUI()
                        .tag(1)
                    // PermissionsPrivacyUI()
                    //     .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .indexViewStyle(.page(backgroundDisplayMode: .never))
                .onChange(of: currentStep) { oldValue, newValue in
                    print("Current step: \(newValue)")
                }
                
                Spacer()
                nextButton
                    .padding(.horizontal, 16)
                skipButton
            }
        }
    }
}

// MARK: - Private UI

private extension PermissionContainerView {
    
    var nextButton: some View {
        DButton(title: "Next") {
            withAnimation {
                currentStep += 1
            }
        }
        .padding(.bottom, 4)
    }
    
    var skipButton: some View {
        Button(action: {
            withAnimation {
                currentStep -= 1
            }
        }) {
            Text("Skip")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
        }
        .accessibilityLabel("Skip")
    }
}

#Preview {
    PermissionContainerView()
}
