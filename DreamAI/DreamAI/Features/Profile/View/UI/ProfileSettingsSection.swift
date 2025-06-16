//
//  ProfileSettingsSection.swift
//  DreamAI
//
//  Created by Shaxzod on 19/04/25
//

import SwiftUI

struct ProfileSettingsSection: View {
    @EnvironmentObject var viewModel: ProfileViewModel
    let exportImportAction: () -> Void
    
    var body: some View {
        Section {
            iCloudRow(toggle: $viewModel.isICloudEnabled)
                .frame(height: 40)
            exportImportRow(action: exportImportAction)
                .frame(height: 40)
        }
        .disabled(!viewModel.isSubscribed)
        .applyIf(!viewModel.isSubscribed) {
            $0.mask(Color.black.opacity(0.5))
        }
    }
}

//MARK: - Private IU

private extension ProfileSettingsSection {
    
    func iCloudRow(toggle: Binding<Bool>) -> some View {
        HStack {
            Image(systemName: "checkmark.icloud.fill")
                .font(.title3)
                .foregroundStyle(Color.appPurple)
            Text("iCloud")
            Spacer()
            if viewModel.isSubscribed {
                Toggle("", isOn: toggle)
                .tint(.appPurple)
            } else {
                Image(systemName: "lock.fill")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    func exportImportRow(action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: "square.and.arrow.down")
                    .font(.title3)
                    .foregroundStyle(Color.appPurple)
                Text("Export/Import")
                    .foregroundStyle(.white)
                Spacer()
                if viewModel.isSubscribed {
                    Image(systemName: "chevron.right")
                        .font(.callout)
                        .foregroundColor(.secondary)
                } else {
                    Image(systemName: "lock.fill")
                        .font(.title3)
                        .tint(.secondary)
                }
            }
        }
    }
}
#Preview {
    List {
        ProfileSettingsSection(exportImportAction: {})
            .environmentObject(ProfileViewModel())
    }
}

//MARK: - applyIf

extension View {
    @ViewBuilder
    func applyIf<T: View>(_ condition: Bool, apply: (Self) -> T) -> some View {
        if condition {
            apply(self)
        } else {
            self
        }
    }
}
