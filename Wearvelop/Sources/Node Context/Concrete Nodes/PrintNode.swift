//
//  PrintNode.swift
//  Wearvelop
//
//  Created by Philip Kluz on 2019-01-14.
//  Copyright © 2019 Philip Kluz. All rights reserved.
//

import UIKit

// Node holding on the latest input value for printing.
public class PrintNode: Node {
    
    // MARK: - PrintNode (Input)
    
    public let input: Socket
    
    // MARK: - PrintNode
    
    public init(value: Value? = nil) {
        self.input = Socket(title: "Input", kind: .input)
        super.init(title: "Print", inputs: [self.input], outputs: [])
        self.input.socketValueChanged = inputValueChanged
        self.input.value = value
    }
    
    public func inputValueChanged(from maybeOldValue: Value?, to maybeNewValue: Value?) {
        delegate?.nodeChanged(self)
    }
}
