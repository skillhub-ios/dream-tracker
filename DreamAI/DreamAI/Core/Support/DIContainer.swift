//
// DIContainer.swift
//
// Created by Cesare on 30.06.2025 on Earth.
// 


import Foundation

enum DIContainer {
    static let coreDataStore = DreamsDataManager()
    static let dreamInterpreter = DreamInterpreter()
    static let interpretationLoadingStore = InterpretationLoadingStore()
    static let moodStore = MoodStore()
    static let analyticsManager = FirebaseAnalyticsManager()
    static let appDataResetManager = AppDataResetManager()
}
