//
// PublisherKey.swift
//
// Created by Cesare on 30.06.2025 on Earth.
// 


import Foundation

enum PublisherKey: String {
    case addDream
    case changeDream
    case updateTags
    case interpretationLoadingStatus
    case hasSubscription
    case onboardingFinished
}

@inlinable
func extractValue<T>(from notification: Notification, as type: T.Type) -> T? {
    notification.userInfo?["value"] as? T
}
