import SwiftUI

struct FeatureLockView: View {
    let feature: Feature
    @StateObject private var featureAccess = FeatureAccessService.shared
    @State private var showSubscriptionView = false
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "lock.fill")
                .font(.system(size: 40))
                .foregroundColor(.accentColor)
            
            Text(featureTitle)
                .font(.title2)
                .bold()
            
            Text(featureDescription)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            Button(action: {
                showSubscriptionView = true
            }) {
                Text("Разблокировать")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .cornerRadius(12)
            }
        }
        .padding()
        .sheet(isPresented: $showSubscriptionView) {
            SubscriptionView()
        }
    }
    
    private var featureTitle: String {
        switch feature {
        case .unlimitedAI:
            return "Неограниченное использование ИИ"
        case .export:
            return "Экспорт снов"
        case .iCloudSync:
            return "Синхронизация с iCloud"
        }
    }
    
    private var featureDescription: String {
        switch feature {
        case .unlimitedAI:
            return "Получите неограниченный доступ к генерации снов с помощью ИИ"
        case .export:
            return "Экспортируйте свои сны в различных форматах"
        case .iCloudSync:
            return "Синхронизируйте ваши сны между устройствами"
        }
    }
}

struct FeatureLockModifier: ViewModifier {
    let feature: Feature
    @StateObject private var featureAccess = FeatureAccessService.shared
    
    func body(content: Content) -> some View {
        Group {
            if featureAccess.canAccessFeature(feature) {
                content
            } else {
                FeatureLockView(feature: feature)
            }
        }
    }
}

extension View {
    func featureLock(_ feature: Feature) -> some View {
        modifier(FeatureLockModifier(feature: feature))
    }
} 