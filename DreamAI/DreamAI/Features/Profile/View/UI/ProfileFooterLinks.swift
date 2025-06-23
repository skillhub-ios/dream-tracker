//
//  ProfileFooterLinks.swift
//  DreamAI
//
//  Created by Shaxzod on 19/04/25
//

import SwiftUI

struct ProfileFooterLinks: View {
    var body: some View {
        // Footer
        Section {
            HStack(spacing: 16) {
                // TODO: Implement footer links
                Button(action: {}) {
                    Text("Privacy Policy")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .underline()
                }
                Button(action: {}) {
                    Text("Terms")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .underline()
                }
                Button(action: {}) {
                    Text("Data Deletion")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .underline()
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
    }
}

#Preview {
    Section {
        ProfileFooterLinks()
    }
    .listRowBackground(Color.appGray4)
}
