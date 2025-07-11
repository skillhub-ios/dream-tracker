//
// DeviceManager.swift
//
// Created by Cesare on 09.07.2025 on Earth.
// 


import SwiftUI

private struct DeviceFamilyKey: EnvironmentKey {
    static let defaultValue: DeviceFamily = {
        switch UIDevice.current.userInterfaceIdiom {
        case .pad: return .pad
        default: return .phone
        }
    }()
}

extension EnvironmentValues {
    var deviceFamily: DeviceFamily {
        get { self[DeviceFamilyKey.self] }
        set { self[DeviceFamilyKey.self] = newValue }
    }
}

enum DeviceFamily {
    case phone, pad
}
