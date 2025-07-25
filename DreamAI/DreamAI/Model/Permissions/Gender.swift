//
//  Gender.swift
//  DreamAI
//
//  Created by Shaxzod on 19/04/25
//

import SwiftUI

enum Gender: String, CaseIterable, Identifiable, Hashable {
    case preferNotToSay = "Prefer not to say"
    case male = "Male"
    case female = "Female"
    case nonBinary = "Non-binary"
    case transMan = "Trans man"
    case transWoman = "Trans woman"
    case other = "Other"
    
    var id: String { rawValue }
    var displayTitle: LocalizedStringKey {
        switch self {
        case .preferNotToSay: "preferNotToSay"
        case .male: "male"
        case .female: "female"
        case .nonBinary: "nonBinary"
        case .transMan: "transMan"
        case .transWoman: "transWoman"
        case .other: "other"
        }
    }
    
}
