//
//  ProfileSubscriptionSection.swift
//  DreamAI
//
//  Created by Shaxzod on 19/04/25
//

import SwiftUI

struct ProfileSubscriptionSection: View {
    var isPremium: Bool
    var plan: String
    var expiry: String
    
    var body: some View {
        Section {
            VStack(alignment: .leading, spacing: 24) {
                HStack {
                    Text("Subscription")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(
                            .linearGradient(
                                colors: [Color(hex: "BF5AF2"), Color(hex: "DA8FFF")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    
                    Spacer()
                    
                    if isPremium {
                        Text(expiry)
                            .font(.callout)
                            .foregroundColor(.secondary)
                    }
                    
                    Image(systemName: "chevron.right")
                        .font(.callout)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    VStack(alignment: .leading) {
                        if isPremium {
                            Text("Your Plan")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            Text(plan)
                                .font(.title2)
                                .bold()
                                .foregroundColor(.primary)
                        } else {
                            Text("Upgrade")
                                .font(.title2).bold()
                                .foregroundColor(.primary)
                        }
                    }
                 
                    Spacer()
                    
                    ZStack {
                        Circle()
                            .fill(Color.purple.opacity(0.15))
                            .frame(width: 56, height: 56)
                        Image(systemName: "crown.fill")
                            .foregroundStyle(
                                .linearGradient(
                                    colors: [Color(hex: "BF5AF2"), Color(hex: "DA8FFF")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .font(.title)
                    }
                }
            }
        }
        
    }
}

#Preview {
    List {
        ProfileSubscriptionSection(isPremium: true, plan: "Monthly", expiry: "18.07.2024")
    }
}
