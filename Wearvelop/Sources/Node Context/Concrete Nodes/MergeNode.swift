//
//  MergeNode.swift
//  Wearvelop
//
//  Created by Philip Kluz on 2019-02-16.
//  Copyright © 2019 Philip Kluz. All rights reserved.
//

import UIKit
import CoreMotion

/// Node that combines a dynamic number of inputs into an single output stream by relaying all values as they come in on one channel.
public class MergeNode: Node {
    
    // MARK: - MergeNode (Output)
    
    public let output: Socket
    
    // MARK: - MergeNode
    
    public init(inputs: Int) {
        let inputSockets = Array(0..<inputs).map { index -> Socket in
            return Socket(title: "\(index)", kind: .input)
        }
        
        self.output = Socket(title: "Result", kind: .output)
        
        super.init(title: "Merge (\(inputs))",
            inputs: inputSockets,
            outputs: [ self.output ])
        
        for socket in inputSockets {
            socket.socketValueChanged = inputValueChanged
        }
    }
    
    private func inputValueChanged(from maybeOldValue: Value?, to maybeNewValue: Value?) {
        output.value = maybeNewValue
    }
}
