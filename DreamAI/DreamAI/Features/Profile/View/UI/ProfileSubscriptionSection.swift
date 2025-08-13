//
//  ProfileSubscriptionSection.swift
//  DreamAI
//
//  Created by Shaxzod on 19/04/25
//

import SwiftUI

struct ProfileSubscriptionSection: View {
    @EnvironmentObject private var subsriptionVeiwModel: SubscriptionViewModel
    
    var body: some View {
        Section {
            VStack(alignment: .leading, spacing: 24) {
                HStack {
                    Text("subscription")
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
                    if subsriptionVeiwModel.isSubscribed {
                        Text(subsriptionVeiwModel.subscriptionExpiry?.dayMonthYear ?? "")
                            .font(.callout)
                            .foregroundColor(.secondary)
                    }
                    Image(systemName: "chevron.right")
                        .font(.callout)
                        .foregroundColor(.secondary)
                }
                HStack {
                    VStack(alignment: .leading) {
                        if subsriptionVeiwModel.isSubscribed {
                            Text("yourPlan")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            Text(subsriptionVeiwModel.subscriptionType.title())
                                .font(.title2)
                                .bold()
                                .foregroundColor(.primary)
                        } else {
                            Text("upgrade")
                                .font(.title2)
                                .bold()
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
        .contentShape(Rectangle())
        .onTapGesture {
            subsriptionVeiwModel.showInternalPaywall()
        }
    }
}

#Preview {
    List {
        ProfileSubscriptionSection()
            .environmentObject(SubscriptionViewModel())
    }
}
