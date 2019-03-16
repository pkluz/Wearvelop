//
//  ConstantNode.swift
//  Wearvelop
//
//  Created by Philip Kluz on 2019-01-14.
//  Copyright © 2019 Philip Kluz. All rights reserved.
//

import UIKit

/// Node that aloways outputs the constant value it was initialized with.
public class ConstantNode: Node {
    
    // MARK: - ConstantNode (Output)
    
    public let output: Socket
    
    // MARK: - ConstantNode
    
    public init(value: Value) {
        self.output = Socket(title: "Output", kind: .output)
        super.init(title: value.compactDisplayString, inputs: [], outputs: [ self.output ])
        self.output.value = value
    }
}
