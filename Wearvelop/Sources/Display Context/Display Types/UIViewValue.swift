//
//  UIViewValue.swift
//  Wearvelop
//
//  Created by Philip Kluz on 2019-03-13.
//  Copyright © 2019 Philip Kluz. All rights reserved.
//

import UIKit

public protocol UIViewValueDelegate: class {
    func viewValueChanged(_ value: UIViewValue)
}

public class UIViewValue: ValueConvertible {
    
    public enum Keys: String {
        case x
        case y
        case width
        case height
        case backgroundColor
        case subviews
        case type
    }
    
    public init?(map maybeMap: Value) {
        guard let map = maybeMap.unwrapAsMap() else { return nil }
        
        let x = map[Keys.x.rawValue]?.unwrapAsCGFloat() ?? 0.0
        let y = map[Keys.y.rawValue]?.unwrapAsCGFloat() ?? 0.0
        let width = map[Keys.width.rawValue]?.unwrapAsCGFloat() ?? 0.0
        let height = map[Keys.height.rawValue]?.unwrapAsCGFloat() ?? 0.0
        
        if width < 0.0 || height < 0 { return nil }
        
        self.frame = CGRect(x: x, y: y, width: width, height: height)
        self.subviews = map[Keys.subviews.rawValue]?.unwrapAsViewValueArray() ?? []
        self.backgroundColor = map[Keys.backgroundColor.rawValue]?.unwrapAsColor() ?? Color.white
    }
    
    public init(frame: CGRect, backgroundColor: Color = .white, subviews: [UIViewValue] = []) {
        self.frame = frame
        self.backgroundColor = backgroundColor
        self.subviews = subviews
    }
    
    public var frame: CGRect
    public var subviews: [UIViewValue]
    public var backgroundColor: Color
    public weak var delegate: UIViewValueDelegate?
    
    public var bounds: CGRect {
        return CGRect(x: 0.0, y: 0.0, width: frame.width, height: frame.height)
    }
    
    public func toView() -> UIView {
        let view = UIView(frame: frame)
        view.backgroundColor = backgroundColor.systemColor
        
        for subviewValue in subviews {
            let subview = subviewValue.toView()
            view.addSubview(subview)
        }
        
        return view
    }
    
    // MARK: - ValueConvertible
    
    public func toValue() -> Value {
        return .map([
            UIViewValue.Keys.x.rawValue: .double(Double(frame.origin.x)),
            UIViewValue.Keys.y.rawValue: .double(Double(frame.origin.y)),
            UIViewValue.Keys.width.rawValue: .double(Double(frame.size.width)),
            UIViewValue.Keys.height.rawValue: .double(Double(frame.size.height)),
            UIViewValue.Keys.backgroundColor.rawValue: .string(backgroundColor.toHex()),
            UIViewValue.Keys.type.rawValue: .string(String(describing: UIViewValue.self)),
            UIViewValue.Keys.subviews.rawValue: .array(subviews.map  { $0.toValue() }),
        ])
    }
}

extension Value {
    
    public func unwrapAsCGFloat() -> CGFloat? {
        switch self {
        case .integer(let value):
            return CGFloat(value)
        case .float(let value):
            return CGFloat(value)
        case .double(let value):
            return CGFloat(value)
        case .string(let value):
            if let value = Float(value) {
                return CGFloat(value)
            }
            return nil
        default:
            return nil
        }
    }
    
    public func unwrapAsColor() -> Color? {
        switch self {
        case .string(let value):
            return Color(hex: value)
        default:
            return nil
        }
    }
    
    public func unwrapAsViewValue() -> UIViewValue? {
        guard let type = self.unwrapAsMap()?[UIViewValue.Keys.type.rawValue]?.unwrapAsString() else { return nil }

        switch type {
        case String(describing: UIViewValue.self):
            return UIViewValue(map: self)
        case String(describing: UISwitchViewValue.self):
            return UISwitchViewValue(map: self)
        default:
            print("Unsupported view type. Cannot decode.")
            return nil
            
        }
    }
    
    public func unwrapAsViewValueArray() -> [UIViewValue] {
        switch self {
        case .array(let values):
            return values.map { $0.unwrapAsViewValue() }.compactMap { $0 }
        default:
            return []
        }
    }
}
