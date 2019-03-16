//
//  UITraitCollection+Convenience.swift
//  Wearvelop
//
//  Created by Philip Kluz on 2018-12-12.
//  Copyright © 2018 Philip Kluz. All rights reserved.
//

import UIKit

public extension UITraitCollection {
    
    public var hasNotch: Bool {
        return (UIApplication.shared.delegate?.window??.safeAreaInsets.bottom ?? 0.0) > 0.0
    }
}
