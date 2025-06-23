//
//  Language.swift
//  DreamAI
//
//  Created by Shaxzod on 10/06/25.
//

import SwiftUI

enum Language: String, CaseIterable, Identifiable {
    case english = "English"
    case romanian = "Română"
    case ukrainian = "Український"
    case kazakh = "қазақ"
    case german = "Deutsch"
    case italian = "Italiano"
    case french = "Français"
    case spanish = "Español"
    case portuguese = "Português"
    case korean = "한국인"
    case japanese = "日本"
    case hindi = "हिंदी"
    case bangla = "বাংলা"
    case arabic = "عرب"
    case turkish = "Türkçe"
    
    var flag: ImageResource {
        return switch self {
        case .english: .flagEngland
        case .romanian: .flagRomania
        case .ukrainian: .flagUkraine
        case .kazakh: .flagKazakhstan
        case .german: .flagGermany
        case .italian: .flagItaly
        case .french: .flagClippertonIsland
        case .spanish: .flagCeutaMelilla
        case .portuguese: .flagPortugal
        case .korean: .flagSouthKorea
        case .japanese: .flagJapan
        case .hindi: .flagIndia
        case .bangla: .flagBangladesh
        case .arabic: .flagUnitedArabEmirates
        case .turkish: .flagTurkey
        }
    }

    var title: String {
        switch self {
        case .english: "English"
        case .romanian: "Română"
        case .ukrainian: "Український"
        case .kazakh: "қазақ"
        case .german: "Deutsch"
        case .italian: "Italiano"
        case .french: "Français"
        case .spanish: "Español"
        case .portuguese: "Português"
        case .korean: "한국인"
        case .japanese: "日本"
        case .hindi: "हिंदी"
        case .bangla: "বাংলা"
        case .arabic: "عرب"
        case .turkish: "Türkçe"
        }
    }
    
    var id: String {
        switch self {
        case .english: "en"
        case .romanian: "ro"
        case .ukrainian: "uk"
        case .kazakh: "kk"
        case .german: "de"
        case .italian: "it"
        case .french: "fr"
        case .spanish: "es"
        case .portuguese: "pt"
        case .korean: "ko"
        case .japanese: "ja"
        case .hindi: "hi"
        case .bangla: "bn"
        case .arabic: "ar"
        case .turkish: "tr"
        }
    }
}

