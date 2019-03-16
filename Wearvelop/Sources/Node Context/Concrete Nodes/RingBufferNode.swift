//
//  RingBufferNode.swift
//  Wearvelop
//
//  Created by Philip Kluz on 2019-02-16.
//  Copyright © 2019 Philip Kluz. All rights reserved.
//

import UIKit

/// A ring buffer node of a predefined size. Input values are added to a ring buffer, and output values are realyed at a pre-defined output rate (in seconds).
public class RingBufferNode: Node {

    // MARK: - RingBufferNode (Input)
    
    public let valueInput: Socket
    public let driverInput: Socket
    
    // MARK: - RingBufferNode (Output)
    
    public let output: Socket
    
    // MARK: - RingBufferNode
    
    private let ringBuffer: RingBuffer
    
    public struct Constants {
        public static let defaultRingBufferSize: Int = 25
    }
    
    public init(capacity: Int = Constants.defaultRingBufferSize) {
        self.valueInput = Socket(title: "Input", kind: .input)
        self.driverInput = Socket(title: "Driver", kind: .input)
        self.output = Socket(title: "Output", kind: .output)
        self.ringBuffer = RingBuffer(capacity: capacity)
        super.init(title: "Ring Buffer (\(capacity))", inputs: [ self.valueInput, self.driverInput ], outputs: [ self.output ])
        self.valueInput.socketValueChanged = inputValueChanged
        self.driverInput.socketValueChanged = driverValueChanged
    }
    
    public func inputValueChanged(from maybeOldValue: Value?, to maybeNewValue: Value?) {
        guard let newValue = maybeNewValue else { return }
        let success = ringBuffer.write(newValue)
        if !success {
            print("Ring buffer write failed. Ring buffer full.")
        }
    }
    
    public func driverValueChanged(from maybeOldValue: Value?, to maybeNewValue: Value?) {
        self.output.value = ringBuffer.read()
    }
}

public class RingBuffer {
    
    private var array: [Value?]
    private var rIndex = 0
    private var wIndex = 0
    
    public init(capacity: Int) {
        array = Array<Value?>(repeating: nil, count: capacity);
    }
    
    @discardableResult
    public func write(_ element: Value) -> Bool {
        if !isFull {
            array[wIndex % array.count] = element
            wIndex += 1
            return true
        }
        
        return false
    }
    
    public func read() -> Value? {
        if !isEmpty {
            let element = array[rIndex % array.count]
            rIndex += 1
            return element
        }
        
        return nil
    }
    
    public var remainingReadCapacity: Int {
        return wIndex - rIndex
    }
    
    public var remainingWriteCapacity: Int {
        return array.count - remainingReadCapacity
    }
    
    public var isEmpty: Bool {
        return remainingReadCapacity == 0
    }
    
    public var isFull: Bool {
        return remainingWriteCapacity == 0
    }
}
