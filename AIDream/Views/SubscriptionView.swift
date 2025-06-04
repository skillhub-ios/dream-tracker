import SwiftUI
import StoreKit

struct SubscriptionView: View {
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @State private var selectedSubscription: Product?
    @State private var errorMessage: String?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    headerView
                    subscriptionOptionsView
                    featuresView
                    trialInfoView
                    restoreButton
                }
                .padding()
            }
            .navigationTitle("Премиум подписка")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Закрыть") {
                        dismiss()
                    }
                }
            }
            .alert("Ошибка", isPresented: .constant(errorMessage != nil)) {
                Button("OK") {
                    errorMessage = nil
                }
            } message: {
                Text(errorMessage ?? "")
            }
            .overlay {
                if subscriptionManager.isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.2))
                }
            }
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 10) {
            Text("Разблокируйте все возможности")
                .font(.title2)
                .bold()
            Text("Получите доступ ко всем функциям приложения")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
    
    private var subscriptionOptionsView: some View {
        VStack(spacing: 15) {
            ForEach(subscriptionManager.subscriptions, id: \.id) { product in
                SubscriptionOptionView(
                    product: product,
                    isSelected: selectedSubscription?.id == product.id,
                    action: {
                        selectedSubscription = product
                        purchaseSubscription(product)
                    }
                )
            }
        }
    }
    
    private var featuresView: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Что включено:")
                .font(.headline)
            
            FeatureRow(icon: "infinity", text: "Неограниченное использование ИИ")
            FeatureRow(icon: "square.and.arrow.up", text: "Экспорт снов")
            FeatureRow(icon: "icloud", text: "Синхронизация с iCloud")
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
    
    private var trialInfoView: some View {
        VStack(spacing: 10) {
            Text("3 дня пробного периода")
                .font(.headline)
            Text("Попробуйте все функции бесплатно")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
    
    private var restoreButton: some View {
        Button("Восстановить покупки") {
            Task {
                do {
                    try await subscriptionManager.restorePurchases()
                } catch {
                    errorMessage = error.localizedDescription
                }
            }
        }
        .font(.subheadline)
    }
    
    private func purchaseSubscription(_ product: Product) {
        Task {
            do {
                try await subscriptionManager.purchase(product)
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}

struct SubscriptionOptionView: View {
    let product: Product
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading) {
                    Text(product.displayName)
                        .font(.headline)
                    Text(product.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text(product.displayPrice)
                    .font(.headline)
            }
            .padding()
            .background(isSelected ? Color.accentColor.opacity(0.1) : Color(.systemBackground))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.accentColor : Color.gray.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .foregroundColor(.accentColor)
            Text(text)
            Spacer()
        }
    }
}

#Preview {
    SubscriptionView()
} 