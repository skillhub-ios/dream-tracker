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
    
    private var iCloudBinding: Binding<Bool> {
        Binding<Bool>(
            get: { viewModel.isICloudEnabled },
            set: { viewModel.userTogglediCloud(to: $0) }
        )
    }
    
    var body: some View {
        Section {
            iCloudRow(toggle: iCloudBinding)
                .frame(height: 40)
            exportImportRow(action: exportImportAction)
                .frame(height: 40)
        }
        .alert("iCloud Sync", isPresented: $viewModel.showiCloudSignInAlert) {
            Button("Sign In") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("Cancel", role: .cancel) {
                viewModel.isICloudEnabled = false
            }
        } message: {
            Text("To enable sync, you need to sign in to your Apple account")
        }
        .alert("iCloud Status", isPresented: $viewModel.showiCloudStatusAlert) {
            Button("OK", role: .cancel) {
                viewModel.resetSyncStatusAlert()
            }
        } message: {
            Text(viewModel.iCloudStatusMessage)
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
