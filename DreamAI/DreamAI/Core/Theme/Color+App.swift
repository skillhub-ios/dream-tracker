//
//  Color+App.swift
//  DreamAI
//
//  Created by Shaxzod on 19/04/25
//

import SwiftUI

extension Color {
    // MARK: - Brand Colors
    /// #DA8FFF - appPurple
    static let appPurple = Color(hex: "DA8FFF")
    /// #261A2C - appPurpleDark
    static let appPurpleDark = Color(hex: "261A2C")
    /// #EBEBF5 - appPurpleLight
    static let appPurpleLight = Color(hex: "EBEBF5")
    /// #382A40 - appPurpleDarkBackground
    static let appPurpleDarkBackground = Color(hex: "382A40")
    /// #523761 - appPurpleDarkStroke
    static let appPurpleDarkStroke = Color(hex: "523761")
    
    // MARK: - Grays
    /// #FFFFFF - appWhite
    static let appWhite = Color(hex: "FFFFFF")
    /// #3C3C43 - appGray1
    static let appGray1 = Color(hex: "3C3C43")
    /// #48484A - appGray2
    static let appGray2 = Color(hex: "48484A")
    /// #2C2C2E - appGray3
    static let appGray3 = Color(hex: "2C2C2E")
    /// #1C1C1E - appGray4
    static let appGray4 = Color(hex: "1C1C1E")
    /// #636366 - appGray5
    static let appGray5 = Color(hex: "636366")
    /// #A1A1A9 - appGray6
    static let appGray6 = Color(hex: "A1A1A9")
    /// #787880 - appGray7
    static let appGray7 = Color(hex: "787880")
    /// #767680 - appGray8
    static let appGray8 = Color(hex: "767680")
    /// #EBEBF5 - appGray9
    static let appGray9 = Color(hex: "EBEBF5")
    /// #4A4A50 - appGray10
    static let appGray10 = Color(hex: "1C1C1E")
    
    // MARK: - Accent Colors
    /// #34A853 - appGreen
    static let appGreen = Color(hex: "34A853")
    /// #4285F4 - appBlue
    static let appBlue = Color(hex: "4285F4")
    /// #EA4335 - appRed
    static let appRed = Color(hex: "EA4335")
    /// #FBBC05 - appYellow
    static let appYellow = Color(hex: "FBBC05")
    /// #FF6482 - appCoral
    static let appCoral = Color(hex: "FF6482")
    /// #FF6961 - appOrange
    static let appOrange = Color(hex: "FF6961")
    /// #32D74B - appGreenLight
    static let appGreenLight = Color(hex: "32D74B")
    /// #64D2FF - appBlueLight
    static let appBlueLight = Color(hex: "64D2FF")
    /// #2E2632 - appPurpleGray
    static let appPurpleGray = Color(hex: "2E2632")
    /// #36273C - appPurpleGrayBackground
    static let appPurpleGrayBackground = Color(hex: "36273C")
    /// #4B3256 - appPurpleDark1
    static let appPurpleGradient1 = Color(hex: "4B3256")
    /// #1F1524 - appPurpleDark2
    static let appPurpleGradient2 = Color(hex: "1F1524")
    /// #DA8FFF - appPurpleDark3
    static let appPurpleGradient3 = Color(hex: "DA8FFF")
    /// #DA8FFF - appPurpleDark4
    static let appPurpleGradient4 = Color(hex: "BF5AF2")
    /// #993781 - darkPurple
    static let darkPurple = Color(hex: "993781")
    /// #C6ACD3 - lightPurple
    static let lightPurple = Color(hex: "C6ACD3")
    
    // MARK: - Hex Initializer
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
} 


let SCREEN_WIDTH = UIScreen.main.bounds.width
let SCREEN_HEIGHT = UIScreen.main.bounds.height
