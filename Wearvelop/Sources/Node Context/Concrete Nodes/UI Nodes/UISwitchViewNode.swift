//
//  UISwitchViewNode.swift
//  Wearvelop
//
//  Created by Philip Kluz on 2019-03-13.
//  Copyright © 2019 Philip Kluz. All rights reserved.
//

import UIKit

public class UISwitchViewNode: UIViewNode, UIViewValueDelegate {
    
    // MARK: - UISwitchViewNode (Outputs)
    
    public let isOnOutput: Socket
    
    // MARK: - UISwitchViewNode
    
    public init(x: Double, y: Double, isOn: Bool, backgroundColor: Color = .white) {
        self.isOnOutput = Socket(title: "On", kind: .output, value: .bool(isOn))
        
        super.init(x: x,
                   y: y,
                   width: 51.0,
                   height: 31.0,
                   title: "UISwitch",
                   backgroundColor: backgroundColor,
                   extraInputs: [],
                   extraOutputs: [ self.isOnOutput ])
    }
    
    private var isOn: Bool = false  {
        didSet { refreshOutput() }
    }
    
    public override func refreshOutput() {
        super.refreshOutput()
        isOnOutput.value = .bool(isOn)
    }
    
    public override func refreshViewValue() {
        super.refreshViewValue()
        _switchViewValue.subviews = subviews
        _switchViewValue.isOn = isOn
    }
    
    public override var viewValue: UIViewValue {
        return _switchViewValue
    }
    
    private lazy var _switchViewValue: UISwitchViewValue =  {
        let value = UISwitchViewValue(frame: frame, backgroundColor: .clear, isOn: isOn, subviews: subviews)
        value.delegate = self
        return value
    }()
    
    // MARK: - UIViewValueDelegate
    
    public func viewValueChanged(_ value: UIViewValue) {
        if let value = value as? UISwitchViewValue {
            self.isOn = value.isOn
        }
    }
}
