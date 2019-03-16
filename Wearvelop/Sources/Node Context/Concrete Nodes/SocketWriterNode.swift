//
//  SocketWriterNode.swift
//  Wearvelop
//
//  Created by Philip Kluz on 2019-01-20.
//  Copyright © 2019 Philip Kluz. All rights reserved.
//

import UIKit
import PKJSONSocket

/// Sends incoming messages to the input ip/port.
public class SocketWriterNode: Node {
    
    // MARK: - SocketWriterNode (Input)
    
    private let ipInput: Socket
    private let portInput: Socket
    private let dataInput: Socket
    
    // MARK: - SocketWriterNode (Output)
    
    private let passthroughOutput: Socket
    
    // MARK: - SocketWriterNode
    
    public init() {
        self.ipInput = Socket(title: "IP", kind: .input)
        self.portInput = Socket(title: "Port", kind: .input)
        self.dataInput = Socket(title: "Data", kind: .input)
        
        self.passthroughOutput = Socket(title: "Passthrough", kind: .output)
        
        super.init(title: "Socket (Writer)", inputs: [ self.dataInput, self.ipInput, self.portInput ], outputs: [ self.passthroughOutput ])
        
        self.ipInput.socketValueChanged = ipInputValueChanged
        self.portInput.socketValueChanged = portInputValueChanged
        self.dataInput.socketValueChanged = dataInputValueChanged
    }
    
    private var socket: PKJSONSocket?
    private var connectedSocket: PKJSONSocket?
    
    fileprivate var isValidConnected: Bool = false
    
    private func connectIfNecessary(ip maybeIp: Value?, port maybePort: Value?) {
        if isValidConnected { return }
        
        connectedSocket?.disconnect()
        connectedSocket = nil
        socket?.disconnect()
        socket = nil
        
        guard let port = maybePort?.unwrapAsInt(), let host = maybeIp?.unwrapAsString() else { return }
        
        socket = PKJSONSocket(delegate: self)
        
        let errorPointer: NSErrorPointer = nil
        
        socket?.connect(toHost: host, onPort: UInt16(port), error: errorPointer)
        
        if let error = errorPointer?.pointee {
            print("Failed connecting to port: \(port). Error: \(error)")
        }
    }
    
    private func portInputValueChanged(from maybeOldValue: Value?, to maybeNewValue: Value?) {
        isValidConnected = false
        connectIfNecessary(ip: ipInput.value, port: portInput.value)
    }
    
    private func ipInputValueChanged(from maybeOldValue: Value?, to maybeNewValue: Value?) {
        isValidConnected = false
        connectIfNecessary(ip: ipInput.value, port: portInput.value)
    }
    
    private func dataInputValueChanged(from maybeOldValue: Value?, to maybeNewValue: Value?) {
        connectIfNecessary(ip: ipInput.value, port: portInput.value)
        
        guard let value = maybeNewValue else { return }
        
        var dictionary: [String: Any] = [:]
        switch value {
        case .string(let value):
            dictionary = [ "root": value ]
        case .bool(let value):
            dictionary =  [ "root": value ]
        case .integer(let value):
            dictionary =  [ "root": value ]
        case .float(let value):
            dictionary =  [ "root": value ]
        case .double(let value):
            dictionary =  [ "root": value ]
        case .array:
            dictionary =  [ "root": value.toDictionary() ?? [] ]
        case .map:
            dictionary = value.toDictionary() as? [String: Any] ?? [:]
        }
        
        let message = PKJSONSocketMessage(dictionary: dictionary)
        socket?.send(message)
        
        self.passthroughOutput.value = value
    }
}

extension SocketWriterNode: PKJSONSocketDelegate {
    
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
        
        if let portValue = portInput.value, let ipValue = ipInput.value {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.connectIfNecessary(ip: ipValue, port: portValue)
            }
        }
    }
    
    public func socket(_ socket: PKJSONSocket!, didReceive dictionary: PKJSONSocketMessage!) {
        // Writer node does not receive data.
    }
}
