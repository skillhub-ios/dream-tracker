//
//  ProfileExitButton.swift
//  DreamAI
//
//  Created by Shaxzod on 19/04/25
//

import SwiftUI

struct ProfileExitButton: View {
    let action: () -> Void
    var body: some View {
        Section {
            Button("Exit") {
                action()
            }
            .tint(.red)
            .frame(maxWidth: .infinity, alignment: .center)
        }
    }
}

#Preview {
    List {
        ProfileExitButton(action: {})
    }
}
