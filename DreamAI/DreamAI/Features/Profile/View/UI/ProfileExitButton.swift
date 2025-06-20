//
//  ProfileExitButton.swift
//  DreamAI
//
//  Created by Shaxzod on 19/04/25
//

import SwiftUI

struct ProfileExitButton: View {
    var body: some View {
        Section {
            Button("Exit") {
                
            }
            .tint(.red)
            .frame(maxWidth: .infinity, alignment: .center)
        }
    }
}

#Preview {
    List {
        ProfileExitButton()
    }
}
