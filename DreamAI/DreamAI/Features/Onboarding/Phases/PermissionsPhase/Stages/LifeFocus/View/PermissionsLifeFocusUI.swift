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
        VStack(spacing: 24) {
            VStack(alignment: .leading) {
                Text("Life Focus")
                    .font(.title2.bold())
                    .foregroundColor(.white)
                Text("To understand your dreams better")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            card
        }
    }
    
    private var card: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Text("💫")
                Text("What's currently top of mind for you?")
                    .foregroundColor(.white)
            }
            .font(.body)
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
                                        .foregroundStyle(LinearGradient.appPurpleHorizontal)
                                        .frame(width: 24, height: 24)
                                } else {
                                    Image(systemName: "circle")
                                        .resizable()
                                        .foregroundColor(Color.white.opacity(0.3))
                                        .frame(width: 24, height: 24)
                                }
                            }
                            .padding(.horizontal, 16)
                            .frame(height: 44)
                        }
                    }
                    if viewModel.allAreas.last != area {
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
    PermissionsLifeFocusUI()
        .background(Color.black)
} 
