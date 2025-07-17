//
// ChatView.swift
//
// Created by Cesare on 16.07.2025 on Earth.
// 


import Foundation

final class ChatViewModel: ObservableObject {
    
    var interpretation: Interpretation
    
    
    init(
        interpretation: Interpretation
    ) {
        self.interpretation = interpretation
    }
    
}



/// В запрос к OpenAI добавить тематики для начала беседы. Получить и распарсить эти данные - done
/// Создать для модель сообщений
/// Настроить отправку и получение сообщений от OpenAI
/// Сохранение чатов
/// Настроить возможность записи и распознования голосовых сообщений?
