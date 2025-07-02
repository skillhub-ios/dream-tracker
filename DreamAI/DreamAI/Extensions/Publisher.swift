//
// Publisher.swift
//
// Created by Cesare on 30.06.2025 on Earth.
// 


import Foundation
import Combine

extension Publisher where Output: Collection {
    func dropIfEmpty() -> Publishers.CompactMap<Self, Output> {
        return self.compactMap { output in
            return output.isEmpty ? nil : output
        }
    }
}
