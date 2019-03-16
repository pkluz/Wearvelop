//
//  BufferNode.swift
//  Wearvelop
//
//  Created by Philip Kluz on 2019-02-05.
//  Copyright © 2019 Philip Kluz. All rights reserved.
//

import UIKit
import CoreMotion

/// Node that buffers a series of incoming values and delivers them as an array of a predefined size.
public class BufferNode: Node {
    
    // MARK: - BufferNode (Input)
    
    public let valuesInput: Socket
    
    // MARK: - BufferNode (Output)
    
    public let bufferOutput: Socket
    
    // MARK: - BufferNode
    
    public struct Constants {
        public static let defaultMaxSize: Int = 5
    }
    
    public let maxSize: Int
    
    public init(size: Int = Constants.defaultMaxSize) {
        self.bufferOutput = Socket(title: "Results", kind: .output)
        self.valuesInput = Socket(title: "Values", kind: .input)
        self.maxSize = size
        
        super.init(title: "Buffer (\(self.maxSize))",
            inputs: [ self.valuesInput ],
            outputs: [ self.bufferOutput ])
        
        self.valuesInput.socketValueChanged = inputValueChanged
    }
    
    private var buffer: [Value] = []
    
    private func inputValueChanged(from maybeOldValue: Value?, to maybeNewValue: Value?) {
        guard let newValue = maybeNewValue else { return }
        
        buffer.append(newValue)
        
        if buffer.count == maxSize {
            self.bufferOutput.value = buffer.toValue()
            buffer = [] // After delivery, clear the buffer.
        }
    }
}
