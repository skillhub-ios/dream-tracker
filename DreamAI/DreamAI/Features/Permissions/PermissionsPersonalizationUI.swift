//
//  PermissionsPersonalizationUI.swift
//  DreamAI
//
//  Created by Shaxzod on 19/04/25
//

import SwiftUI

struct PermissionsPersonalizationUI: View {
    @StateObject private var viewModel = PermissionsPersonalizationViewModel()
    
    var body: some View {
        VStack(spacing: 24) {
            VStack(alignment: .leading) {
                Text("Quick Personalization")
                    .font(.title2.bold())
                    .foregroundColor(.white)
                Text("A few quick details to personalize insights")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            ageGenderCard
            beliefCard
            
            Spacer()
        }
        .padding(.horizontal, 16)
    }
    
    private var ageGenderCard: some View {
        VStack(spacing: 12) {
            Menu {
                ForEach(viewModel.allAges) { age in
                    Button(age.displayTitle) {
                        viewModel.selectedAge = age
                    }
                }
            } label: {
                menuRow(title: "Age range", value: viewModel.selectedAge.displayTitle)
            }
            Menu {
                ForEach(viewModel.allGenders) { gender in
                    Button(gender.displayTitle) {
                        viewModel.selectedGender = gender
                    }
                }
            } label: {
                menuRow(title: "Gender", value: viewModel.selectedGender.displayTitle)
            }
        }
        .padding(16)
        .background(Color.appPurpleDark)
        .cornerRadius(16)
    }
    
    private func menuRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .foregroundColor(.white)
            Spacer()
            Text(value)
                .foregroundColor(.white.opacity(0.7))
            Image(systemName: "chevron.down")
                .foregroundColor(.white.opacity(0.5))
        }
        .frame(height: 44)
        .padding(.horizontal, 8)
        .background(Color.white.opacity(0.05))
        .cornerRadius(10)
    }
    
    private var beliefCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Do you believe dreams have meaning?")
                .font(.headline)
                .foregroundColor(.white)
            VStack(spacing: 0) {
                ForEach(viewModel.allBeliefs) { belief in
                    Button(action: {
                        viewModel.selectedBelief = belief
                    }) {
                        HStack {
                            Text(belief.displayTitle)
                                .font(.system(size: 19))
                                .foregroundColor(.white)
                            Spacer()
                            if viewModel.selectedBelief == belief {
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
                    if viewModel.allBeliefs.last != belief {
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
    PermissionsPersonalizationUI()
        .padding()
        .background(Color.black)
} 
