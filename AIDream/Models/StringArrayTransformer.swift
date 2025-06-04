import Foundation

@objc(StringArrayTransformer)
final class StringArrayTransformer: ValueTransformer {
    
    static let name = NSValueTransformerName(rawValue: "StringArrayTransformer")
    
    override class func transformedValueClass() -> AnyClass {
        return NSArray.self
    }
    
    override class func allowsReverseTransformation() -> Bool {
        return true
    }
    
    override func transformedValue(_ value: Any?) -> Any? {
        guard let stringArray = value as? [String] else { return nil }
        return try? NSKeyedArchiver.archivedData(withRootObject: stringArray, requiringSecureCoding: true)
    }
    
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? Data else { return nil }
        return try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSArray.self, from: data) as? [String]
    }
}

// Регистрация трансформатора
extension StringArrayTransformer {
    static func register() {
        let transformer = StringArrayTransformer()
        ValueTransformer.setValueTransformer(transformer, forName: name)
    }
} 