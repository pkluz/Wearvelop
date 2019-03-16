//
//  Link.swift
//  Wearvelop
//
//  Created by Philip Kluz on 2019-02-05.
//  Copyright © 2019 Philip Kluz. All rights reserved.
//

import Foundation

public class Link: Equatable, Hashable {
    
    public typealias Source = (node: Node, socket: Socket)
    public typealias Target = (node: Node, socket: Socket)
    
    public let source: Source
    public let target: Target
    
    public init(source: Source, target: Target) {
        self.source = source
        self.target = target
    }
    
    public func activate() {
        if isActive { return }
        
        self.source.socket.add(observer: self) { [weak self] (oldValue, newValue) in
            self?.target.socket.isConnected = true
            self?.target.socket.value = newValue
        }
        isActive = true
        
        // Forcefully replay current value.
        self.source.socket.value = self.source.socket.value
    }
    
    public func deactivate() {
        self.source.socket.remove(observer: self)
        
        // Forcefully replay delete current value.
        self.target.socket.isConnected = false
        self.target.socket.value = nil
        
        isActive = false
    }
    
    public private(set) var isActive: Bool = false
    
    // MARK: - Equatable
    
    public static func == (lhs: Link, rhs: Link) -> Bool {
        return lhs.source.node == rhs.source.node &&
               lhs.target.node == rhs.target.node &&
               lhs.source.socket == rhs.source.socket &&
               lhs.target.socket == rhs.target.socket
    }
    
    // MARK: - Hashable
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(source.socket)
        hasher.combine(source.node)
        hasher.combine(target.socket)
        hasher.combine(target.node)
    }
}
