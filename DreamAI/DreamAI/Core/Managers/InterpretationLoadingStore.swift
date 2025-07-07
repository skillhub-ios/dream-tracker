//
// InterpretationLoadingStore.swift
//
// Created by Cesare on 07.07.2025 on Earth.
//


import Foundation

final class InterpretationLoadingStore {
    
    // MARK: - Private Properties
    
    private var tasks: [UUID: Task<Interpretation, Error>] = [:]
    
    // MARK: - External Dependencies
    
    private let dreamInterpreter = DIContainer.dreamInterpreter
    
    func loadInterpretation(
        dream: Dream
    ) async throws -> Interpretation {
        let id = dream.id
        
        // Проверяем есть ли активные запросы с текущим id
        if let existing = tasks[id] {
            do {
                let result = try await existing.value
                return result
            } catch {
                throw error
            }
        }
        
        // Создаём новый запрос
        let task = Task<Interpretation, Error> {
            try await dreamInterpreter.interpretDream(
                dreamText: dream.description,
                mood: dream.emoji
            )
        }
        
        tasks[id] = task
        
        do {
            let result = try await task.value
            tasks[id] = nil
            return result
        } catch {
            tasks[id] = nil
            throw error
        }
    }
}
