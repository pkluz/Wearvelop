//
//  Value.swift
//  Wearvelop
//
//  Created by Philip Kluz on 2018-12-20.
//  Copyright © 2018 Philip Kluz. All rights reserved.
//

import Foundation

/// Value is effectively what constitutes the Wearvelop typesystem.
public indirect enum Value {
    case string(String)
    case integer(Int)
    case float(Float)
    case double(Double)
    case bool(Bool)
    case array([Value])
    case map([String: Value])
    
    public func toDictionary() -> Any? {
        switch self {
        case .string(let value):
            return value
        case .integer(let value):
            return value
        case .float(let value):
            return value
        case .double(let value):
            return value
        case .bool(let value):
            return value
        case .array(let values):
            return values.map { $0.toDictionary() }
        case .map(let values):
            var result: [String: Any] = [:]
            for (key, value) in values {
                result[key] = value.toDictionary()
            }
            return result
        }
    }
    
    public var displayString: String {
        switch self {
        case .string(let value):
            return "string(\(value))"
        case .integer(let value):
            return "integer(\(value))"
        case .float(let value):
            return "float(\(value))"
        case .double(let value):
            return "double(\(value))"
        case .bool(let value):
            return "bool(\(value))"
        case .array(let values):
            return "[\(values.map { $0.displayString })]"
        case .map(let values):
            return "[\(values.enumerated().map { "\($0.element.key):\($0.element.value.displayString)" })]"
        }
    }
    
    public var compactDisplayString: String {
        switch self {
        case .string(let value):
            let prefix = value.prefix(5)
            let appendDots = value.count > 5
            return "string(\(prefix + (appendDots ? "…" : "")))"
        case .integer(let value):
            return "integer(\(value))"
        case .float(let value):
            return "float(\(value))"
        case .double(let value):
            return "double(\(value))"
        case .bool(let value):
            return "bool(\(value))"
        case .array(let values):
            return "array(#\(values.count))"
        case .map(let values):
            return "map(#\(values.keys.count))"
        }
    }
    
    public func unwrapAsDouble() -> Double? {
        switch self {
        case .integer(let value):
            return Double(value)
        case .float(let value):
            return Double(value)
        case .double(let value):
            return value
        case .string(let value):
            return Double(value)
        default:
            return nil
        }
    }
    
    public func unwrapAsFloat() -> Float? {
        switch self {
        case .integer(let value):
            return Float(value)
        case .float(let value):
            return value
        case .double(let value):
            return Float(value)
        case .string(let value):
            return Float(value)
        default:
            return nil
        }
    }
    
    public func unwrapAsInt() -> Int? {
        switch self {
        case .integer(let value):
            return value
        case .float(let value):
            return Int(value)
        case .double(let value):
            return Int(value)
        case .string(let value):
            return Int(value)
        default:
            return nil
        }
    }
    
    public func unwrapAsString() -> String? {
        switch self {
        case .string(let value):
            return value
        default:
            return nil
        }
    }
    
    public func unwrapAsArray() -> [Value]? {
        switch self {
        case .array(let values):
            return values
        default:
            return nil
        }
    }
}

extension Value: Equatable {
    
    public static func == (lhs: Value, rhs: Value) -> Bool {
        switch (lhs, rhs) {
        case (.string(let valueA), .string(let valueB)):
            return valueA == valueB
        case (.integer(let valueA), .integer(let valueB)):
            return valueA == valueB
        case (.float(let valueA), .float(let valueB)):
            return valueA == valueB
        case (.double(let valueA), .double(let valueB)):
            return valueA == valueB
        case (.bool(let valueA), .bool(let valueB)):
            return valueA == valueB
        case (.array(let valuesA), .array(let valuesB)):
            return valuesA == valuesB
        case (.map(let valuesA), .map(let valuesB)):
            return valuesA == valuesB
        default:
            return false
        }
    }
}

extension Value: Hashable {
    
    public var hashValue: Int {
        let result: Int = {
            switch self {
            case .string(let value):
                return "string".hashValue ^ value.hashValue
            case .integer(let value):
                return "integer".hashValue ^ value.hashValue
            case .float(let value):
                return "float".hashValue ^ value.hashValue
            case .double(let value):
                return "double".hashValue ^ value.hashValue
            case .bool(let value):
                return "bool".hashValue ^ value.hashValue
            case .array(let values):
                return "array".hashValue ^ values.hashValue
            case .map(let values):
                return "map".hashValue ^ values.hashValue
            }
        }()
        
        return result &* 16777619 // Large prime for better hashing behavior.
    }
}

extension Value: CustomStringConvertible {
    public var description: String {
        switch self {
        case .string(let value):
            return "string(\(value))"
        case .integer(let value):
            return "integer(\(value))"
        case .float(let value):
            return "float(\(value))"
        case .double(let value):
            return "double(\(value))"
        case .bool(let value):
            return "bool(\(value))"
        case .array(let values):
            return "array[\n\(values.map { "  \($0.description)" }.joined(separator: ",\n"))\n]"
        case .map(let values):
            let readableValues = values.map { (key: String, value: Value) -> String in
                return "  \(key) => \(value.description)"
            }.joined(separator: ",\n")
            return "map[\n\(readableValues)\n]"
        }
    }
}

public protocol ValueConvertible {
    func toValue() -> Value
}

extension String: ValueConvertible {

    public func toValue() -> Value {
        return .string(self)
    }

    // Attempts to cast a string to a typed value of a different (more specific) kind.
    public func toCastValue() -> Value {
        switch trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) {
        case "true":
            return .bool(true)
        case "false":
            return .bool(false)
        case let value:
            // Attempt to interpret as a JSON array
            if value.hasPrefix("[") && value.hasSuffix("]") {
                var result: [Value] = []
                if let data = self.data(using: .utf8) {
                    if let partial = (try? JSONSerialization.jsonObject(with: data, options: [.allowFragments])) as? [ValueConvertible] {
                        for convertible in partial {
                            result.append(convertible.toValue())
                        }
                    }
                }
                return .array(result)
            }
            
            // Attempt to interpret as a JSON dictionary
            if value.hasPrefix("{") && value.hasSuffix("}") {
                var result: [String: Value] = [:]
                if let data = self.data(using: .utf8) {
                    if let partial = (try? JSONSerialization.jsonObject(with: data, options: [.allowFragments])) as? [String: Any] {
                        for (key, maybeConvertible) in partial {
                            if let convertible = maybeConvertible as? ValueConvertible {
                                result[key] = convertible.toValue()
                            }
                        }
                    }
                }
                
                return .map(result)
            }
            
            if value.contains(".") {
                // Attempt to interpret as a double value.
                if let doubleValue = Double(value) {
                    return .double(doubleValue)
                }
            } else {
                // Attempt to interpret as an integer
                if let integerValue = Int(value) {
                    return .integer(integerValue)
                }
            }
            
            return .string(value)
        }
    }
}

extension NSNumber: ValueConvertible {
    public func toValue() -> Value {
        return self.doubleValue.toValue()
    }
}

extension NSArray: ValueConvertible {
    public func toValue() -> Wearvelop.Value {
        var result: [Wearvelop.Value] = []
        
        for valueCandidate in self {
            guard let value = valueCandidate as? ValueConvertible else { continue }
            result.append(value.toValue())
        }
        
        return .array(result)
    }
}

extension NSDictionary: ValueConvertible {
    public func toValue() -> Wearvelop.Value {
        var result: [String: Wearvelop.Value] = [:]
        
        for (keyCandidate, valueCandidate) in self {
            guard let key = keyCandidate as? String else { continue }
            guard let value = valueCandidate as? ValueConvertible else { continue }
            result[key] = value.toValue()
        }
        
        return .map(result)
    }
}

extension Float: ValueConvertible {
    public func toValue() -> Value {
        return .float(self)
    }
}

extension Double: ValueConvertible {
    public func toValue() -> Value {
        return .double(self)
    }
}

extension Int: ValueConvertible {
    public func toValue() -> Value {
        return .integer(self)
    }
}

extension Bool: ValueConvertible {
    public func toValue() -> Value {
        return .bool(self)
    }
}

extension Array where Element: ValueConvertible {
    public func toValue() -> Value {
        return .array(self.map { $0.toValue() })
    }
}

extension Dictionary where Key == String, Value: ValueConvertible {
    public func toValue() -> Wearvelop.Value {
        let result: [String: Wearvelop.Value] = reduce([String: Wearvelop.Value]()) { sum, next -> [String: Wearvelop.Value] in
            var newSum = sum
            newSum[next.key] = next.value.toValue()
            return newSum
        }
        
        return .map(result)
    }
}

extension Value: ValueConvertible {
    public func toValue() -> Value {
        return self
    }
}

extension Value {
    
    public func value(for keyPath: [String]) -> Value? {
        if keyPath.count == 0 { return nil }
        if keyPath.count == 1, let key = keyPath.first {
            return value(for: key)
        }
        
        if let head = keyPath.first {
            let tail = Array(keyPath[1..<keyPath.count])
            let value = self.value(for: head)
            return value?.value(for: tail)
        }
        
        return nil
    }
    
    public func value(for key: String) -> Value? {
        switch self {
        case .map(let values):
            return values[key]
        default:
            return nil
        }
    }
}

extension Value {
    
    public func value(at index: Int) -> Value? {
        switch self {
        case .array(let values):
            return values[safe: index]
        default:
            return nil
        }
    }
}
