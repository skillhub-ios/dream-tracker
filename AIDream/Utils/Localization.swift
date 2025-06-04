import Foundation

enum L10n {
    // Общие
    static let ok = NSLocalizedString("OK", comment: "")
    static let cancel = NSLocalizedString("Отмена", comment: "")
    static let save = NSLocalizedString("Сохранить", comment: "")
    static let delete = NSLocalizedString("Удалить", comment: "")
    static let edit = NSLocalizedString("Редактировать", comment: "")
    static let error = NSLocalizedString("Ошибка", comment: "")
    static let success = NSLocalizedString("Успешно", comment: "")
    
    // Навигация
    static let dreams = NSLocalizedString("Сны", comment: "")
    static let settings = NSLocalizedString("Настройки", comment: "")
    static let profile = NSLocalizedString("Профиль", comment: "")
    static let back = NSLocalizedString("Назад", comment: "")
    
    // Сны
    static let newDream = NSLocalizedString("Новый сон", comment: "")
    static let dreamContent = NSLocalizedString("Содержание сна", comment: "")
    static let dreamDate = NSLocalizedString("Дата сна", comment: "")
    static let dreamMood = NSLocalizedString("Настроение", comment: "")
    static let dreamTags = NSLocalizedString("Теги", comment: "")
    static let addTag = NSLocalizedString("Добавить тег", comment: "")
    static let removeTag = NSLocalizedString("Удалить тег", comment: "")
    static let interpretDream = NSLocalizedString("Интерпретировать сон", comment: "")
    static let dreamInterpretation = NSLocalizedString("Интерпретация сна", comment: "")
    static let dreamSymbols = NSLocalizedString("Символы", comment: "")
    static let dreamEmotions = NSLocalizedString("Эмоции", comment: "")
    static let dreamRecommendations = NSLocalizedString("Рекомендации", comment: "")
    
    // Настроения
    static let moodHappy = NSLocalizedString("Счастливый", comment: "")
    static let moodSad = NSLocalizedString("Грустный", comment: "")
    static let moodScared = NSLocalizedString("Испуганный", comment: "")
    static let moodAngry = NSLocalizedString("Злой", comment: "")
    static let moodNeutral = NSLocalizedString("Нейтральный", comment: "")
    
    // Настройки
    static let appearance = NSLocalizedString("Внешний вид", comment: "")
    static let darkMode = NSLocalizedString("Темная тема", comment: "")
    static let language = NSLocalizedString("Язык", comment: "")
    static let notifications = NSLocalizedString("Уведомления", comment: "")
    static let security = NSLocalizedString("Безопасность", comment: "")
    static let faceID = NSLocalizedString("Face ID", comment: "")
    static let subscription = NSLocalizedString("Подписка", comment: "")
    static let restorePurchases = NSLocalizedString("Восстановить покупки", comment: "")
    static let support = NSLocalizedString("Поддержка", comment: "")
    static let feedback = NSLocalizedString("Обратная связь", comment: "")
    static let privacyPolicy = NSLocalizedString("Политика конфиденциальности", comment: "")
    static let termsOfService = NSLocalizedString("Условия использования", comment: "")
    static let about = NSLocalizedString("О приложении", comment: "")
    static let version = NSLocalizedString("Версия", comment: "")
    
    // Опасная зона
    static let dangerousZone = NSLocalizedString("Опасная зона", comment: "")
    static let resetData = NSLocalizedString("Сбросить данные", comment: "")
    static let logout = NSLocalizedString("Выйти", comment: "")
    
    // Алерты
    static let deleteConfirmation = NSLocalizedString("Удалить сон?", comment: "")
    static let deleteConfirmationMessage = NSLocalizedString("Это действие нельзя отменить", comment: "")
    static let resetConfirmation = NSLocalizedString("Сбросить все данные?", comment: "")
    static let resetConfirmationMessage = NSLocalizedString("Все ваши сны будут удалены безвозвратно", comment: "")
    static let logoutConfirmation = NSLocalizedString("Выйти из аккаунта?", comment: "")
    static let logoutConfirmationMessage = NSLocalizedString("Вы сможете войти снова в любое время", comment: "")
    
    // Ошибки
    static let networkError = NSLocalizedString("Ошибка сети", comment: "")
    static let authError = NSLocalizedString("Ошибка авторизации", comment: "")
    static let syncError = NSLocalizedString("Ошибка синхронизации", comment: "")
    static let saveError = NSLocalizedString("Ошибка сохранения", comment: "")
    static let deleteError = NSLocalizedString("Ошибка удаления", comment: "")
    static let interpretationError = NSLocalizedString("Ошибка интерпретации", comment: "")
    
    // Успех
    static let dreamSaved = NSLocalizedString("Сон сохранен", comment: "")
    static let dreamDeleted = NSLocalizedString("Сон удален", comment: "")
    static let dataReset = NSLocalizedString("Данные сброшены", comment: "")
    static let loggedOut = NSLocalizedString("Вы вышли из аккаунта", comment: "")
    static let purchasesRestored = NSLocalizedString("Покупки восстановлены", comment: "")
} 