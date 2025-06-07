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
        VStack(spacing: 24) {
            VStack(alignment: .leading) {
                Text("Hi there 👋")
                    .font(.title2.bold())
                    .foregroundColor(.white)
                Text("Let's help you get more accurate dream insights")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            card
        }
        .padding(.horizontal, 16)
    }
    
    private var card: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Text("🧚‍♀️")
                    .font(.title2)
                Text("How do your dreams usually feel?")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            
            VStack(spacing:0) {
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
                                    .frame(width: 24, height: 24)
                            } else {
                                Image(systemName: "circle")
                                    .resizable()
                                    .foregroundColor(Color.white.opacity(0.3))
                                    .frame(width: 24, height: 24)
                            }
                        }
                        .frame(height: 44)
                    }
                    
                    if viewModel.allFeelings.last != feeling {
                        Divider()
                    }
                }
            }
            .padding(10)
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
        .padding()
        .animatedGradientBackground()
}
