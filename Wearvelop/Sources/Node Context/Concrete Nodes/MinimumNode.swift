//
//  MinimumNode.swift
//  Wearvelop
//
//  Created by Philip Kluz on 2019-01-14.
//  Copyright © 2019 Philip Kluz. All rights reserved.
//

import UIKit

/// The minimum node operates on arrays of numerical values and emits the minimum of that array.
public class MinimumNode: Node {
    
    // MARK: - MinimumNode (Input)
    
    private let input: Socket
    
    // MARK: - MinimumNode (Output)
    
    private let output: Socket
    
    // MARK: - MinimumNode
    
    public init() {
        self.input = Socket(title: "Input", kind: .input)
        self.output = Socket(title: "Output", kind: .output)
        
        super.init(title: "Minimum", inputs: [ self.input ], outputs: [ self.output ])
        
        self.input.socketValueChanged = inputValueChanged
    }
    
    public func inputValueChanged(from maybeOldValue: Value?, to maybeNewValue: Value?) {
        guard let newValue = maybeNewValue?.unwrapAsArray() else { return }
        let numericalArray = newValue
            .map { value -> Double? in
                return value.unwrapAsDouble()
            }
            .compactMap { $0 }
        
        if let minimum = numericalArray.min() {
            self.output.value = .double(minimum)
        }
    }
}
