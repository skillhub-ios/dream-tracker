//
//  Gender.swift
//  DreamAI
//
//  Created by Shaxzod on 19/04/25
//

import Foundation

enum Gender: String, CaseIterable, Identifiable, Hashable {
    case preferNotToSay = "Prefer not to say"
    case male = "Male"
    case female = "Female"
    case nonBinary = "Non-binary"
    case transMan = "Trans man"
    case transWoman = "Trans woman"
    case other = "Other"
    
    var id: String { rawValue }
    var displayTitle: String { rawValue }
} 