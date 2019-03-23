//
//  UISwitchViewValue.swift
//  Wearvelop
//
//  Created by Philip Kluz on 2019-03-14.
//  Copyright © 2019 Philip Kluz. All rights reserved.
//

import UIKit

public class UISwitchViewValue: UIViewValue {
    
    public enum Keys: String {
        case isOn
    }
    
    public var isOn: Bool = false
    
    public override init?(map maybeMap: Value) {
        guard let map = maybeMap.unwrapAsMap() else { return nil }
        guard let prospectiveType = map[UIViewValue.Keys.type.rawValue]?.unwrapAsString() else { return nil }
        guard prospectiveType == String(describing: UISwitchViewValue.self) else { return nil }
        guard let isOn = map[UISwitchViewValue.Keys.isOn.rawValue]?.unwrapAsBool() else { return nil }
        self.isOn = isOn
        super.init(map: maybeMap)
    }
    
    public init(frame: CGRect, backgroundColor: Color, isOn: Bool, subviews: [UIViewValue] = []) {
        self.isOn = isOn
        super.init(frame: frame, backgroundColor: backgroundColor, subviews: subviews)
    }
    
    private var changeHandler: (UIView) -> Void = { _ in }
    
    public override func toView() -> UIView {
        let view = UISwitch(frame: frame)
        view.isOn = isOn
        view.backgroundColor = backgroundColor.systemColor
        view.addTarget(self, action: #selector(viewChanged(_:)), for: .valueChanged)
        
        // Technically there's no reason for a switch to have a subview but hey,... power to you.
        for subviewValue in subviews {
            let subview = subviewValue.toView()
            view.addSubview(subview)
        }
        
        return view
    }
    
    @objc private func viewChanged(_ sender: UISwitch) {
        isOn = sender.isOn
        delegate?.viewValueChanged(self)
    }
    
    // MARK: - ValueConvertible
    
    public override func toValue() -> Value {
        guard var mapValue = super.toValue().unwrapAsMap() else {
            return super.toValue()
        }
        
        mapValue[UISwitchViewValue.Keys.isOn.rawValue] = .bool(isOn)
        mapValue[UIViewValue.Keys.type.rawValue] = .string(String(describing: UISwitchViewValue.self))
        
        return .map(mapValue)
    }
}
