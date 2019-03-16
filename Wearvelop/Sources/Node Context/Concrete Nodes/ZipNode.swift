//
//  MergeNode.swift
//  Wearvelop
//
//  Created by Philip Kluz on 2019-02-02.
//  Copyright © 2019 Philip Kluz. All rights reserved.
//

import UIKit
import CoreMotion

/// Combines all the most recent outputs of all inputs into a single array. A new value is only generated once each input delivers a value.
public class ZipNode: Node {
    
    // MARK: - ZipNode (Output)
    
    public let output: Socket
    
    // MARK: - ZipNode
    
    public init(inputs: Int) {
        let inputSockets = Array(0..<inputs).map { index -> Socket in
            return Socket(title: "\(index)", kind: .input)
        }
        
        self.output = Socket(title: "Result", kind: .output)
        
        super.init(title: "Zip (\(inputs))",
            inputs: inputSockets,
            outputs: [ self.output ])
        
        for socket in inputSockets {
            queues[socket] = []
            socket.socketValueChanged = { [weak socket, weak self] oldValue, newValue in
                guard let socket = socket, let self = self else { return }
                self.inputValueChanged(for: socket, from: oldValue, to: newValue)
            }
        }
    }
    
    private var queues: [ Socket: [Value] ] = [:]
    
    public func queue(for socket: Socket) -> [Value]? {
        return queues[socket]
    }
    
    private var nextOutputValue: [Value]? {
        var result: [Value] = []
        
        for (socket, queue) in queues {
            if let first = queue.first {
                result.append(first)
                queues[socket] = queue
            }
        }
        
        if result.count == inputs.count {
            let queues = self.queues
        
            for (socket, queue) in queues {
                var queue = queue
                queue.removeFirst()
                self.queues[socket] = queue
            }
        
            return result
        }
        
        return nil
    }
    
    private func allSocketsConnected() -> Bool {
        return inputs.reduce(true) { sum, next -> Bool in
            return sum && next.isConnected
        }
    }
    
    private func inputValueChanged(for socket: Socket, from maybeOldValue: Value?, to maybeNewValue: Value?) {
        // Asset that all inputs are connected - only then do we start buffering (thereby making sure things are in sync).
        if !allSocketsConnected() { return }
        
        guard let newValue = maybeNewValue, var queue = self.queue(for: socket) else { return }
        queue.append(newValue)
        queues[socket] = queue
        
        if let nextOutput = nextOutputValue {
            output.value = .array(nextOutput)
        }
    }
}
