//
//  LowPassFilterNode.swift
//  Wearvelop
//
//  Created by Philip Kluz on 2019-01-15.
//  Copyright © 2019 Philip Kluz. All rights reserved.
//

import UIKit

/// NOTE: LowPassFilterNode operates on double types only.
///       All other numeric types (and strings) will be attempted to be cast to double.
public class LowPassFilterNode: Node {
    
    // MARK: - LowPassFilterNode (Inputs)
    
    public let valueInput: Socket
    public let smoothingFactorInput: Socket
    
    // MARK: - LowPassFilterNode (Outputs)
    
    public let output: Socket
    
    // MARK: - LowPassFilterNode
    
    public struct Constants {
        public static let defaultSmoothingFactor: Double = 0.1
    }
    
    public init(smoothingFactor: Double = Constants.defaultSmoothingFactor) {
        self.valueInput = Socket(title: "Value", kind: .input)
        self.smoothingFactorInput = Socket(title: "Smoothing", kind: .input, value: .double(smoothingFactor))
        self.output = Socket(title: "Result", kind: .output)
        super.init(title: "Low-Pass Filter", inputs: [ self.valueInput, self.smoothingFactorInput ], outputs: [ self.output ])
        self.valueInput.socketValueChanged = inputValueChanged
    }
    
    public func inputValueChanged(from maybeOldValue: Value?, to maybeNewValue: Value?) {
        let maybeOldValue = maybeOldValue?.unwrapAsDouble()
        let maybeNewValue = maybeNewValue?.unwrapAsDouble()
        let smoothingFactor = smoothingFactorInput.value?.unwrapAsDouble() ?? Constants.defaultSmoothingFactor
        
        switch (maybeOldValue, maybeNewValue) {
        case (.some(let old), .some(let new)):
            let lowPassValue = (smoothingFactor * new) + (old * (1.0 - smoothingFactor))
            self.output.value = .double(lowPassValue)
        case (.none, .some(let new)):
            self.output.value = .double(new)
        default:
            self.output.value = nil
        }
    }
}
