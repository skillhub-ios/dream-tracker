//
// AppDataResetManager.swift
//
// Created by Cesare on 11.07.2025 on Earth.
// 


import Foundation

protocol AppDataResettable {
    func resetAppData()
}

final class AppDataResetManager {
    
    private var resettableModules: [AppDataResettable] = []

    func register(_ module: AppDataResettable) {
        resettableModules.append(module)
    }

    func resetAll() {
        resettableModules.forEach { $0.resetAppData() }
    }
}
