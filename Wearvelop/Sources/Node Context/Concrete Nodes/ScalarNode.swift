//
//  ScalarNode.swift
//  Wearvelop
//
//  Created by Philip Kluz on 2019-02-01.
//  Copyright © 2019 Philip Kluz. All rights reserved.
//

import UIKit

/// Scales an input by a predefined value provided on the other input.
public class ScalarNode: Node {
    
    // MARK: - ScalarNode (Input)
    
    public let input: Socket

    // MARK: - ScalarNode (Output)
    
    public let output: Socket
    
    // MARK: - ScalarNode
    
    public let scalar: Socket
    
    public init() {
        self.input = Socket(title: "Value", kind: .input)
        self.scalar = Socket(title: "Scalar", kind: .input)
        self.output = Socket(title: "Result", kind: .output)
        super.init(title: "Scalar", inputs: [ self.input, self.scalar ], outputs: [ self.output ])
        input.socketValueChanged = inputValueChanged
        scalar.socketValueChanged = scalarValueChanged
    }
    
    public func inputValueChanged(from maybeOldValue: Value?, to maybeNewValue: Value?) {
        guard let inputValue = maybeNewValue?.unwrapAsDouble(), let scalarValue = scalar.value?.unwrapAsDouble() else {
            self.output.value = nil
            return
        }
        self.output.value = .double(inputValue * scalarValue)
    }
    
    public func scalarValueChanged(from maybeOldValue: Value?, to maybeNewValue: Value?) {
        guard let inputValue = input.value?.unwrapAsDouble(), let scalarValue = maybeNewValue?.unwrapAsDouble() else {
            self.output.value = nil
            return
        }
        self.output.value = .double(inputValue * scalarValue)
    }
}
