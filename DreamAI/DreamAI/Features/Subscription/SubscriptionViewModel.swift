//
// SubscriptionViewModel.swift
//
// Created by Cesare on 27.06.2025 on Earth.
// 


import Foundation

final class SubscriptionViewModel: ObservableObject {
    @Published var paywallIsPresent: Bool = false
    @Published var activeSubscription: SubscriptionType?
    @Published var selectedSubscription: SubscriptionType = .monthly
}

enum SubscriptionType: CaseIterable, Identifiable {
    case monthly
    case yearly
    
    var title: String {
        switch self {
        case .monthly: "Monthly"
        case .yearly: "Yearly"
        }
    }
    
    var id: Self { self }
}
