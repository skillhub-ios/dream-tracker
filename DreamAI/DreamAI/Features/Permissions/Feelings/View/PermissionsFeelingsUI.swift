//
//  PermissionsFeelingsView.swift
//  DreamAI
//
//  Created by Shaxzod on 19/04/25
//

import SwiftUI

struct PermissionsFeelingsUI: View {
    @StateObject private var viewModel = PermissionsFeelingsViewModel()
    
    var body: some View {
        VStack(spacing: 12) {
            titleView
                .frame(maxWidth: .infinity, alignment: .leading)
            cardView
        }
        .padding(.horizontal, 16)
    }
}

private extension PermissionsFeelingsUI {
    var titleView: some View {
        VStack(alignment: .leading) {
            Text("Hi there 👋")
                .font(.title2.bold())
                .foregroundColor(.white)
            Text("Let's help you get more accurate dream insights")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))
        }
    }
    
    var cardView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("🔮 How do your dreams usually feel?")
                .font(.headline)
                .foregroundColor(.white)
            VStack(spacing: .zero) {
                ForEach(viewModel.allFeelings) { feeling in
                    Button(action: {
                        viewModel.toggleFeeling(feeling)
                    }) {
                        HStack {
                            Text(feeling.title)
                                .font(.system(size: 19))
                                .foregroundColor(.white)
                            Spacer()
                            if viewModel.selectedFeelings.contains(feeling) {
                                Image(systemName: "checkmark.circle.fill")
                                    .resizable()
                                    .foregroundColor(.purple)
                                    .frame(width: 22, height: 22)
                            } else {
                                Image(systemName: "circle")
                                    .resizable()
                                    .foregroundColor(Color.white.opacity(0.3))
                                    .frame(width: 22, height: 22)
                            }
                        }
                        .frame(height: 44)
                        .padding(.horizontal, 16)
                    }
                    if viewModel.allFeelings.last != feeling {
                        Divider()
                            .frame(maxWidth: .infinity)
                    }
                }
            }
            .background(Color.appPurpleDark.mix(with: .white, by: 0.05).opacity(0.75))
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .padding(16)
        .background(Color.appPurpleDark)
        .cornerRadius(16)
    }
}

#Preview {
    PermissionsFeelingsUI()
        .animatedGradientBackground()
}
