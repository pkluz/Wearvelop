//
//  SocketListenerNode.swift
//  Wearvelop
//
//  Created by Philip Kluz on 2019-01-20.
//  Copyright © 2019 Philip Kluz. All rights reserved.
//

import UIKit
import PKJSONSocket

/// Listens for incoming messages on the input port and relays them as values as they come in.
public class SocketListenerNode: Node {
    
    // MARK: - SocketListenerNode (Input)
    
    private let portInput: Socket
    
    // MARK: - SocketListenerNode (Output)
    
    private let output: Socket
    
    // MARK: - SocketListenerNode
    
    public init() {
        self.portInput = Socket(title: "Port", kind: .input)
        
        self.output = Socket(title: "Output", kind: .output)
        
        super.init(title: "Socket (Listener)", inputs: [ self.portInput ], outputs: [ self.output ])
        
        self.portInput.socketValueChanged = portInputValueChanged
    }
    
    private var socket: PKJSONSocket?
    private var connectedSocket: PKJSONSocket?
    fileprivate var isValidConnected: Bool = false
    
    private func connectIfNecessary(port maybePort: Value?) {
        if isValidConnected { return }
        connectedSocket?.disconnect()
        connectedSocket = nil
        socket?.disconnect()
        socket = nil

        guard let port = maybePort?.unwrapAsInt() else { return }

        socket = PKJSONSocket(delegate: self)
        
        let errorPointer: NSErrorPointer = nil
        
        socket?.listen(onPort: UInt16(port), error: errorPointer)
        
        if let error = errorPointer?.pointee {
            print("Failed listening on port: \(port). Error: \(error)")
        }
    }
    
    private func portInputValueChanged(from maybeOldValue: Value?, to maybeNewValue: Value?) {
        isValidConnected = false
        connectIfNecessary(port: maybeNewValue)
    }
}

extension SocketListenerNode: PKJSONSocketDelegate {
    
    public func socket(_ socket: PKJSONSocket!, didAcceptNewSocket newSocket: PKJSONSocket!) {
        newSocket.delegate = self
        isValidConnected = true
        connectedSocket = newSocket
    }
    
    public func socket(_ socket: PKJSONSocket!, didConnectToHost host: String!) {
        isValidConnected = true
    }
    
    public func socket(_ socket: PKJSONSocket!, didDisconnectWithError error: Error!) {
        isValidConnected = false
        
        if let portValue = portInput.value {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.connectIfNecessary(port: portValue)
            }
        }
    }
    
    public func socket(_ socket: PKJSONSocket!, didReceive dictionary: PKJSONSocketMessage!) {
        let message = dictionary.dictionaryRepresentation() as NSDictionary
        
        if let rootNode = message["root"] as? ValueConvertible {
            self.output.value = rootNode.toValue()
        } else {
            self.output.value = message.toValue()
        }
    }
}
