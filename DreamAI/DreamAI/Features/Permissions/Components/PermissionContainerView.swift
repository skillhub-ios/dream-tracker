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
                AppGradients.purpleToBlack
                    .ignoresSafeArea()
                VStack(spacing: 24) {
                    paginationIndicator
                    contentView
                        .frame(maxHeight: .infinity, alignment: .top)
                    Spacer()
                    buttonsContainerView
                        .padding(.horizontal, 16)
                }
            }
            .toolbarVisibility(.hidden, for: .navigationBar)
            .navigationDestination(isPresented: $showSettings) {
                PermissionsSettingsUI()
            }
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
    
    var contentView: some View {
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
    }
    
    var buttonsContainerView: some View {
        VStack(spacing: 12) {
            Button(action: {
                if currentStep < 2 {
                    withAnimation {
                        currentStep += 1
                    }
                } else {
                    showSettings = true
                }
            }, label: {
                Text("Next")
            })
            .buttonStyle(PrimaryButtonStyle())
            
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
}

#Preview {
    PermissionContainerView()
}
