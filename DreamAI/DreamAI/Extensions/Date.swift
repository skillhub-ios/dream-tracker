//
// Date.swift
//
// Created by Cesare on 10.07.2025 on Earth.
// 

import Foundation

extension Date {
    var dayMonthYear: String {
        formatted(.dateTime.day().month(.twoDigits).year())
    }
}
