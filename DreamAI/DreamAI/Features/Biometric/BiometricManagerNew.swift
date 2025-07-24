//
// BiometricManagerNew.swift
//
// Created by Cesare on 24.07.2025 on Earth.
// 


import LocalAuthentication
import Foundation

// MARK: - BiometricManager

final class BiometricManagerNew: ObservableObject {
    
    // MARK: - Properties
    
    /// Показывает, активна ли биометрия на устройстве
    @Published var isBiometricEnabled: Bool = false
    
    private let context = LAContext()
    private let UDKey = "biometric_enabled"
    
    // MARK: - Enums
    
    enum BiometricType {
        case none
        case touchID
        case faceID
        case opticID // Для новых устройств
        
        var description: String {
            switch self {
            case .none:
                return "Biometric not available"
            case .touchID:
                return "Touch ID"
            case .faceID:
                return "Face ID"
            case .opticID:
                return "Optic ID"
            }
        }
    }
    
    enum BiometricError: Error, LocalizedError {
        case notAvailable
        case notEnrolled
        case passcodeNotSet
        case permissionDenied
        case authenticationFailed
        case userCancel
        case systemCancel
        case unknown(Error)
        
        var errorDescription: String? {
            switch self {
            case .notAvailable:
                return "Биометрическая аутентификация недоступна на данном устройстве"
            case .notEnrolled:
                return "Биометрические данные не настроены"
            case .passcodeNotSet:
                return "Пароль устройства не установлен"
            case .permissionDenied:
                return "Доступ к биометрии запрещен"
            case .authenticationFailed:
                return "Аутентификация не удалась"
            case .userCancel:
                return "Пользователь отменил аутентификацию"
            case .systemCancel:
                return "Система отменила аутентификацию"
            case .unknown(let error):
                return "Неизвестная ошибка: \(error.localizedDescription)"
            }
        }
    }
    
    // MARK: - Initialization
    
    init() {
        self.isBiometricEnabled = UserDefaults.standard.bool(forKey: "biometric_enabled")
        updateBiometricStatus()
    }
    
    // MARK: - Public Methods
    
    /// Получает тип доступной биометрии на устройстве
    func getAvailableBiometricType() -> BiometricType {
        var error: NSError?
        
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return .none
        }
        
        switch context.biometryType {
        case .none:
            return .none
        case .touchID:
            return .touchID
        case .faceID:
            return .faceID
        case .opticID:
            return .opticID
        @unknown default:
            return .none
        }
    }
    
    /// Проверяет доступность биометрии
    func isBiometricAvailable() -> Bool {
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
    }
    
    /// Запрашивает разрешение пользователя на использование биометрии
    /// - Parameter reason: Причина запроса биометрической аутентификации
    /// - Returns: Результат аутентификации
    func requestBiometricPermission(reason: String = "Подтвердите свою личность") async -> Result<Void, BiometricError> {
        // Создаем новый контекст для каждого запроса
        let authContext = LAContext()
        
        // Проверяем доступность биометрии
        var error: NSError?
        guard authContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            if let authError = error {
                return .failure(mapLAError(authError))
            }
            return .failure(.notAvailable)
        }
        
        do {
            let success = try await authContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason)
            if success {
                await MainActor.run {
                    self.isBiometricEnabled = true
                    UserDefaults.standard.set(true, forKey: "biometric_enabled")
                }
                return .success(())
            } else {
                return .failure(.authenticationFailed)
            }
        } catch {
            let biometricError = mapLAError(error)
            return .failure(biometricError)
        }
    }
    
    /// Аутентификация с использованием биометрии или пароля устройства
    /// - Parameter reason: Причина запроса аутентификации
    /// - Returns: Результат аутентификации
    func authenticateWithBiometricOrPasscode(reason: String = "Подтвердите свою личность") async -> Result<Void, BiometricError> {
        let authContext = LAContext()
        
        var error: NSError?
        guard authContext.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) else {
            if let authError = error {
                return .failure(mapLAError(authError))
            }
            return .failure(.notAvailable)
        }
        
        do {
            let success = try await authContext.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason)
            if success {
                return .success(())
            } else {
                return .failure(.authenticationFailed)
            }
        } catch {
            let biometricError = mapLAError(error)
            return .failure(biometricError)
        }
    }
    
    /// Отключает биометрию
    func disableBiometric() {
        DispatchQueue.main.async {
            self.isBiometricEnabled = false
            UserDefaults.standard.set(false, forKey: "biometric_enabled")
        }
    }
    
    /// Обновляет статус биометрии
    func updateBiometricStatus() {
        DispatchQueue.main.async {
            self.isBiometricEnabled = self.isBiometricAvailable()
        }
    }
    
    /// Получает детальную информацию о состоянии биометрии
    func getBiometricStatus() -> (isAvailable: Bool, type: BiometricType, isEnrolled: Bool) {
        var error: NSError?
        let isAvailable = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        let type = getAvailableBiometricType()
        
        // Проверяем, настроена ли биометрия
        let isEnrolled: Bool
        if let error = error {
            isEnrolled = error.code != LAError.biometryNotEnrolled.rawValue
        } else {
            isEnrolled = isAvailable
        }
        
        return (isAvailable: isAvailable, type: type, isEnrolled: isEnrolled)
    }
    
    // MARK: - Private Methods
    
    /// Преобразует ошибку LAError в BiometricError
    private func mapLAError(_ error: Error) -> BiometricError {
        guard let laError = error as? LAError else {
            return .unknown(error)
        }
        
        switch laError.code {
        case .biometryNotAvailable:
            return .notAvailable
        case .biometryNotEnrolled:
            return .notEnrolled
        case .passcodeNotSet:
            return .passcodeNotSet
        case .userCancel:
            return .userCancel
        case .systemCancel:
            return .systemCancel
        case .authenticationFailed:
            return .authenticationFailed
        case .biometryLockout:
            return .authenticationFailed
        default:
            return .unknown(error)
        }
    }
}
