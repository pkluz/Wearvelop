//
//  Node.swift
//  Wearvelop
//
//  Created by Philip Kluz on 2018-12-20.
//  Copyright © 2018 Philip Kluz. All rights reserved.
//

import Foundation

public protocol NodeDelegate: class {
    func node(_ node: Node, addedOutgoingLink: Link)
    func node(_ node: Node, addedIncomingLink: Link)
    func node(_ node: Node, removedOutgoingLink: Link)
    func node(_ node: Node, removedIncomingLink: Link)
    func nodeChanged(_ node: Node)
}

public class Node: NSObject {
    
    // MARK: - Node
    
    public let title: String
    public private(set) var inputs: [Socket]
    public private(set) var outputs: [Socket]
    public private(set) var outgoingLinks: [Link]
    public private(set) var incomingLinks: [Link]
    
    public weak var delegate: NodeDelegate?
    
    private let id: String = UUID().uuidString

    public init(title: String, inputs: [Socket], outputs: [Socket]) {
        self.title = title
        self.inputs = inputs
        self.outputs = outputs
        self.outgoingLinks = []
        self.incomingLinks = []
    }
    
    // MARK: - Node (Linking)
    
    @discardableResult
    public func addLink(from sourceSocket: Socket, to targetNode: Node, targetSocket: Socket) -> Bool {
        let link = Link(source: (self, sourceSocket), target: (targetNode, targetSocket))
        let incoming = targetNode.addIncoming(link: link)
        if !incoming { return false }
        let outgoing = addOutgoing(link: link)
        return outgoing && incoming
    }
    
    @discardableResult
    public func remove(link: Link) -> Bool {
        let incoming = link.target.node.removeIncoming(link: link)
        if !incoming { return false }
        let outgoing = link.source.node.removeOutgoing(link: link)
        return outgoing && incoming
    }
    
    // MARK: - Node (Linking - Outgoing)
    
    @discardableResult
    private func addOutgoingLink(from sourceSocket: Socket, to targetNode: Node, targetSocket: Socket) -> Bool {
        let link = Link(source: (self, sourceSocket), target: (targetNode, targetSocket))
        return addOutgoing(link: link)
    }
    
    @discardableResult
    private func addOutgoing(link: Link) -> Bool {
        // Invariant that assures the link can be added in the first place (i.e. correct origin and target)
        if !self.outputs.contains(link.source.socket) || !link.target.node.inputs.contains(link.target.socket) {
            return false
        }
        
        if !outgoingLinks.contains(link) {
            outgoingLinks.append(link)
            link.activate()
            delegate?.node(self, addedOutgoingLink: link)
        }
        
        return link.isActive
    }
    
    @discardableResult
    private func removeOutgoingLink(from sourceSocket: Socket, to targetNode: Node, targetSocket: Socket) -> Bool {
        // Invariant that assures the link can be added in the first place (i.e. correct origin and target)
        if !self.outputs.contains(sourceSocket) || !targetNode.inputs.contains(targetSocket) {
            return true
        }
        
        let links = self.outgoingLinks.filter { link -> Bool in
            return link.source.node == self && link.source.socket == sourceSocket && link.target.node == targetNode && link.target.socket == targetSocket
        }
        
        var success: [Bool] = []
        for link in links {
            success.append(removeOutgoing(link: link))
        }
        
        return success.reduce(true) { $0 && $1 }
    }
    
    @discardableResult
    private func removeOutgoing(link: Link) -> Bool {
        let maybeIndex = outgoingLinks.firstIndex(of: link)
        if let index = maybeIndex {
            link.deactivate()
            outgoingLinks.remove(at: index)
            link.target.node.removeIncoming(link: link)
            delegate?.node(self, removedOutgoingLink: link)
        }
        
        return !link.isActive
    }
    
    // MARK: - Node (Linking - Incoming)
    
    @discardableResult
    private func addIncomingLink(from sourceNode: Node, sourceSocket: Socket, to targetSocket: Socket) -> Bool {
        let link = Link(source: (sourceNode, sourceSocket), target: (self, targetSocket))
        return addIncoming(link: link)
    }
    
    @discardableResult
    private func addIncoming(link: Link) -> Bool {
        // Invariant that assures the link can be added in the first place (i.e. correct origin and target)
        if !self.inputs.contains(link.target.socket) || !link.source.node.outputs.contains(link.source.socket) {
            return false
        }
        
        // Invariant that assures input exclusivity.
        let result = self.incomingLinks.filter { candidate -> Bool in
            return candidate.target.socket == link.target.socket
        }
        if !result.isEmpty { return false }
        
        if !incomingLinks.contains(link) {
            incomingLinks.append(link)
            link.activate()
            delegate?.node(self, addedIncomingLink: link)
        }
        
        return link.isActive
    }
    
    @discardableResult
    private func removeIncomingLink(from sourceNode: Node, sourceSocket: Socket, to targetSocket: Socket) -> Bool {
        // Invariant that assures the link can be added in the first place (i.e. correct origin and target)
        if !self.inputs.contains(targetSocket) || !sourceNode.outputs.contains(sourceSocket) {
            return true
        }
        
        let links = self.incomingLinks.filter { link -> Bool in
            return link.source.node == sourceNode &&
                   link.source.socket == sourceSocket &&
                   link.target.node == self &&
                   link.target.socket == targetSocket
        }
        
        var success: [Bool] = []
        for link in links {
            success.append(removeIncoming(link: link))
        }
        
        return success.reduce(true) { $0 && $1 }
    }
    
    @discardableResult
    private func removeIncoming(link: Link) -> Bool {
        let maybeIndex = incomingLinks.firstIndex(of: link)
        if let index = maybeIndex {
            link.deactivate()
            incomingLinks.remove(at: index)
            link.source.node.removeOutgoing(link: link)
            delegate?.node(self, removedIncomingLink: link)
        }
        
        return !link.isActive
    }
    
    // MARK: - Equatable
    
    public static func == (lhs: Node, rhs: Node) -> Bool {
        return lhs.id == rhs.id
    }
    
    // MARK: - Hashable
    
    public override var hash: Int {
        return id.hash
    }
}
