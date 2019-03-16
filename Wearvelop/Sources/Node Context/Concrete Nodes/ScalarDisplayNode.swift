//
//  ScalarDisplayNode.swift
//  Wearvelop
//
//  Created by Philip Kluz on 2019-02-06.
//  Copyright © 2019 Philip Kluz. All rights reserved.
//

import UIKit

public class ScalarDisplayNode: DisplayNode {
    
    public init() {
        super.init(node: ScalarNode())
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
