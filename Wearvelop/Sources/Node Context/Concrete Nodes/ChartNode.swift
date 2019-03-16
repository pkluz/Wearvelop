//
//  ChartNode.swift
//  Wearvelop
//
//  Created by Philip Kluz on 2019-02-11.
//  Copyright © 2019 Philip Kluz. All rights reserved.
//

import UIKit

/// Node that collects a series of incoming values for display purposes.
public class ChartNode: Node {
    
    // MARK: - CollectorNode (Input)
    
    public let capacityInput: Socket
    
    // MARK: - CollectorNode
    
    public struct Constants {
        public static let defaultMaxSize: Int = 500
    }
    
    public var capacity: Int
    
    public init(capacity: Int = Constants.defaultMaxSize, inputs: Int = 1) {
        let inputSockets = Array(0..<inputs).map { index -> Socket in
            return Socket(title: "\(index)", kind: .input)
        }
        
        self.capacityInput = Socket(title: "Capacity", kind: .input)
        self.capacity = capacity
        
        super.init(title: "Chart",
                   inputs: inputSockets + [ self.capacityInput ],
                   outputs: [ ])
        
        for socket in inputSockets {
            buffers[socket] = []
            socket.socketValueChanged = { [weak socket, weak self] oldValue, newValue in
                guard let socket = socket, let self = self else { return }
                self.inputValueChanged(for: socket, from: oldValue, to: newValue)
            }
        }
        
        self.capacityInput.socketValueChanged = capacityValueChanged
    }
    
    private var buffers: [ Socket: [Value] ] = [:]
    
    public func buffer(for socket: Socket) -> [Value]? {
        return buffers[socket]
    }
    
    private func inputValueChanged(for socket: Socket, from maybeOldValue: Value?, to maybeNewValue: Value?) {
        guard let newValue = maybeNewValue, var buffer = self.buffer(for: socket) else { return }
        
        if !(buffer.count < capacity) {
            if buffer.count > 3 {
                buffer.removeFirst(3)
            } else {
                buffer.removeAll()
            }
        }
        
        buffer.append(newValue)
        buffers[socket] = buffer
        
        delegate?.nodeChanged(self)
    }
    
    private func capacityValueChanged(from maybeOldValue: Value?, to maybeNewValue: Value?) {
        guard let newValue = maybeNewValue?.unwrapAsInt() else { return }
        capacity = newValue
    }
}
