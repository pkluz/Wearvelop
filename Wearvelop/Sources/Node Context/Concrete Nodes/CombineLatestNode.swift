//
//  CombineLatestNode.swift
//  Wearvelop
//
//  Created by Philip Kluz on 2019-02-16.
//  Copyright © 2019 Philip Kluz. All rights reserved.
//

import UIKit
import CoreMotion

/// Node that combines a dynamic number of inputs into an single output with an array of same arity.
public class CombineLatestNode: Node {
    
    // MARK: - CombineLatestNode (Output)
    
    public let output: Socket
    
    // MARK: - CombineLatestNode
    
    public init(inputs: Int) {
        let inputSockets = Array(0..<inputs).map { index -> Socket in
            return Socket(title: "\(index)", kind: .input)
        }
        
        self.output = Socket(title: "Result", kind: .output)
        
        super.init(title: "Combine Latest (\(inputs))",
            inputs: inputSockets,
            outputs: [ self.output ])
        
        for socket in inputSockets {
            socket.socketValueChanged = inputValueChanged
        }
    }
    
    private func inputValueChanged(from maybeOldValue: Value?, to maybeNewValue: Value?) {
        var values: [Value] = []
        
        for maybeValue in inputs.map({ $0.value }) {
            if let value = maybeValue {
                values.append(value)
            } else {
                return
            }
        }
        
        output.value = .array(values)
    }
}
