//
// PaywallView.swift
//
// Created by Cesare on 26.06.2025 on Earth.
//

import SwiftUI

struct PaywallView: View {
    
    @EnvironmentObject var viewModel: SubscriptionViewModel
    
    var body: some View {
        ZStack(alignment: .top) {
            Color.appPurpleGray
                .edgesIgnoringSafeArea(.all)
            VStack(spacing: 16) {
                headerView
                subscriptionInfoView
                segmentPickerView
                Spacer()
                footerView
            }
            .padding([.horizontal, .top], 16)
        }
    }
}

private extension PaywallView {
    var headerView: some View {
        VStack {
            HStack {
                Image(.xMarkCircled)
                    .resizable()
                    .frame(width: 28, height: 28)
                    .opacity(0)
                Spacer()
                Text("Dream Tracker +")
                    .font(.title.bold())
                    .foregroundStyle(Color.appPurple)
                Spacer()
                Button {
                    viewModel.paywallIsPresent.toggle()
                } label: {
                    Image(.xMarkCircled)
                        .resizable()
                        .frame(width: 28, height: 28)
                }
            }
            Text(viewModel.activeSubscription != nil ? "You’ve unlocked all features" : "Unlock Full Access")
                .foregroundStyle(.white)
        }
    }
    
    var subscriptionInfoView: some View {
        VStack(spacing: 10) {
            Text("With subscription")
                .bold()
            HStack {
                Text("Free")
                Spacer()
                Text("Premium")
            }
            .font(.callout)
            .padding(.horizontal, 44)
            VStack(spacing: .zero) {
                ForEach(SubscriptionOptions.allCases) {
                    subscriptionInfoRowView(option: $0)
                    if $0 != .export {
                        Divider()
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(Color.appPurpleGrayBackground)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
              .stroke(Color.appPurpleDarkStroke, lineWidth: 1)
          )
    }
    
    func subscriptionInfoRowView(option: SubscriptionOptions) -> some View {
        HStack(alignment: .center) {
            HStack(spacing: 10) {
                subscriptionInfoRowImage(isAvailable: option.isAvailableInFreeVersion())
                Text(option.rawValue)
                    .font(.subheadline)
                    .foregroundStyle(.white)
            }
            Spacer()
            HStack(spacing: 10) {
                Text(option.rawValue)
                    .font(.subheadline)
                    .foregroundStyle(.white)
                subscriptionInfoRowImage()
            }
        }
        .frame(height: 44)
    }
    
    func subscriptionInfoRowImage(isAvailable: Bool = true) -> some View {
        Image(isAvailable ? .checkmarkSealFill : .multiplyCircleFill)
            .resizable()
            .frame(width: 16, height: 16)
    }
    
    var segmentPickerView: some View {
        SubscriptionSegmentPicker(selection: $viewModel.selectedSubscription) {
            ForEach(SubscriptionType.allCases) { type in
                Text(type.title)
                    .font(.callout)
                    .foregroundStyle(.white)
                    .segmentedControlItemTag(type)
            }
        }
        .opacity(viewModel.activeSubscription == nil ? 1 : 0)
    }
    
    var footerView: some View {
        VStack(spacing: 10) {
            DButton(title: actionButtonTitle(subscription: viewModel.activeSubscription)) {
                
            }
            .opacity(viewModel.activeSubscription == .yearly ? 0 : 1)
            Group {
                Text("Then $39.99 USD/year. Cancel anytime.")
                    .font(.footnote)
                Button {
                    
                } label: {
                    Text("Restore")
                        .underline()
                }
            }
            .font(.footnote)
            .foregroundColor(.appGray9.opacity(0.6))
        }
    }
    
    func actionButtonTitle(subscription: SubscriptionType?) -> String {
        guard let subscription else { return "🔓 Start your 3-day free trial" }
        switch subscription {
        case .monthly:
            return "Upgrade to $39.99 USD/year"
        default:
            return ""
        }
    }
    
    enum SubscriptionOptions: String, CaseIterable, Identifiable {
        
        var id: Self { self }
        
        case dreamLogging = "Dream logging"
        case moodTracking = "Mood tracking"
        case aiInterpretation = "AI interpretation"
        case iCloudSync = "iCloud sync"
        case protectJournal = "Protect journal"
        case aiDreamInsights = "AI Dream Insights"
        case export = "Export"
        
        func isAvailableInFreeVersion() -> Bool {
            switch self {
            case .dreamLogging: return true
            default: return false
            }
        }
    }
}

#Preview {
    PaywallView()
        .environmentObject(SubscriptionViewModel())
}
