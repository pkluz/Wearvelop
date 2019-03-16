//
//  MaximumNode.swift
//  Wearvelop
//
//  Created by Philip Kluz on 2019-01-14.
//  Copyright © 2019 Philip Kluz. All rights reserved.
//

import UIKit

/// The maximum node operates on arrays of numerical values and emits the maximum of that array.
public class MaximumNode: Node {
    
    // MARK: - MaximumNode (Input)
    
    private let input: Socket
    
    // MARK: - MaximumNode (Output)
    
    private let output: Socket
    
    // MARK: - MaximumNode
    
    public init() {
        self.input = Socket(title: "Input", kind: .input)
        self.output = Socket(title: "Output", kind: .output)
        
        super.init(title: "Maximum", inputs: [ self.input ], outputs: [ self.output ])
        
        self.input.socketValueChanged = inputValueChanged
    }
    
    public func inputValueChanged(from maybeOldValue: Value?, to maybeNewValue: Value?) {
        guard let newValue = maybeNewValue?.unwrapAsArray() else { return }
        let numericalArray = newValue
            .map { value -> Double? in
                return value.unwrapAsDouble()
            }
            .compactMap { $0 }
        
        if let maximum = numericalArray.max() {
            self.output.value = .double(maximum)
        }
    }
}
