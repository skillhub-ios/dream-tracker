//
//  PermissionsLifeFocusUI.swift
//  DreamAI
//
//  Created by Shaxzod on 19/04/25
//

import SwiftUI

struct PermissionsLifeFocusUI: View {
    @StateObject private var viewModel = PermissionsLifeFocusViewModel()
    
    var body: some View {
        VStack(spacing: 12) {
            titleView
                .frame(maxWidth: .infinity, alignment: .leading)
            card
        }
        .padding(.horizontal, 16)
    }
}

private extension PermissionsLifeFocusUI {
    var titleView: some View {
        VStack(alignment: .leading) {
            Text("Life Focus")
                .font(.title2.bold())
                .foregroundColor(.white)
            Text("To understand your dreams better")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))
        }
    }
    
    var card: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("💫 What's currently top of mind for you?")
                .font(.headline)
                .foregroundColor(.white)
            Text("1–3")
                .font(.caption)
                .foregroundColor(.white.opacity(0.5))
            VStack(spacing: .zero) {
                ForEach(viewModel.allAreas) { area in
                    VStack(spacing: 10) {
                        Button(action: {
                            viewModel.toggleArea(area)
                        }) {
                            HStack {
                                Text(area.title)
                                    .font(.system(size: 19))
                                    .foregroundColor(.white)
                                Spacer()
                                if viewModel.selectedAreas.contains(area) {
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
                        .disabled(!viewModel.selectedAreas.contains(area) && viewModel.selectedAreas.count >= 3)
                    }
                    if viewModel.allAreas.last != area {
                        Divider()
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
    PermissionsLifeFocusUI()
        .background(Color.black)
}
