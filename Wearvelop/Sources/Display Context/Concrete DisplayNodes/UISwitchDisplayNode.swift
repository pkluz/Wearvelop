//
//  UISwitchNode.swift
//  Wearvelop
//
//  Created by Philip Kluz on 2019-03-14.
//  Copyright © 2019 Philip Kluz. All rights reserved.
//

import UIKit

public final class UISwitchDisplayNode: UIViewDisplayNode {
    
    public init(x: Double = 0.0,
                y: Double = 0.0,
                isOn: Bool = false) {
        let node = UISwitchViewNode(x: x, y: y, isOn: false)
        super.init(node: node, preferredWidth: 51.0, preferredHeight: 31.0)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
