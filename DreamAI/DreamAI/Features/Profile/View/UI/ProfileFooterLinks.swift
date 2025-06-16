//
//  ProfileFooterLinks.swift
//  DreamAI
//
//  Created by Shaxzod on 19/04/25
//

import SwiftUI

struct ProfileFooterLinks: View {
    var body: some View {
        HStack(spacing: 16) {
            // TODO: Implement footer links
            Text("Privacy Policy")
                .font(.footnote)
                .foregroundColor(.secondary)
            Text("Terms")
                .font(.footnote)
                .foregroundColor(.secondary)
            Text("Data Deletion")
                .font(.footnote)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    ProfileFooterLinks()
} 