//
//  ProfileSettingsSection.swift
//  DreamAI
//
//  Created by Shaxzod on 19/04/25
//

import SwiftUI

struct ProfileSettingsSection: View {
    @ObservedObject var viewModel: ProfileViewModel
    var body: some View {
        VStack(spacing: 12) {
            // TODO: Implement settings rows (iCloud, Export/Import, Language, Face ID, Notifications, Bedtime, Wake-up)
            Text("Settings section placeholder")
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    ProfileSettingsSection(viewModel: ProfileViewModel())
} 