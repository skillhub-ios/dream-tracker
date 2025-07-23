//
// PermissionSettingsView.swift
//
// Created by Cesare on 23.07.2025 on Earth.
// 


import SwiftUI

struct PermissionSettingsView: View {
    
    @StateObject private var viewModel: PermissionSettingsViewModel = .init()
    
    var body: some View {
        Text("List of Settings")
    }
}

#Preview {
    PermissionSettingsView()
}
