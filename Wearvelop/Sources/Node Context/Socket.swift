//
//  Socket.swift
//  Wearvelop
//
//  Created by Philip Kluz on 2018-12-20.
//  Copyright © 2018 Philip Kluz. All rights reserved.
//

import Foundation

public class Socket: Equatable, Hashable {
    
    public enum Kind: String {
        case input
        case output
    }
    
    public typealias SocketValueChangedAction = (Value?, Value?) -> Void
    
    private let id: String = UUID().uuidString
    
    public let title: String
    public let kind: Socket.Kind
    public var value: Value? {
        didSet {
            notifyObservers(oldValue: oldValue, newValue: value)
            socketValueChanged(oldValue, value)
        }
    }
    public var socketValueChanged: SocketValueChangedAction
    public var isConnected: Bool = false
    
    public init(title: String, kind: Kind, value: Value? = nil) {
        self.title = title
        self.value = value
        self.kind = kind
        self.socketValueChanged = { _, _ in }
    }
    
    private var observers: [Link: SocketValueChangedAction] = [:]
    
    public func add(observer: Link, change: @escaping SocketValueChangedAction) {
        if observers[observer] != nil {
            print("Warning. Overriding an active observer.")
        }
        observers[observer] = change
        
        isConnected = observers.keys.count > 0
    }
    
    public func remove(observer: Link) {
        observers[observer] = nil
        isConnected = observers.keys.count > 0
    }
    
    private func notifyObservers(oldValue: Value?, newValue: Value?) {
        for (_, action) in observers {
            action(oldValue, newValue)
        }
    }
    
    // MARK: - Equatable
    
    public static func == (lhs: Socket, rhs: Socket) -> Bool {
        return lhs.id == rhs.id
    }
    
    // MARK: - Hashable
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
