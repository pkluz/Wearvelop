//
//  DisplayContext.swift
//  Wearvelop
//
//  Created by Philip Kluz on 2019-02-05.
//  Copyright © 2019 Philip Kluz. All rights reserved.
//

import UIKit

public final class DisplayContext {
    
    // MARK: - Context
    
    public init(parentController: UIViewController, contentView: UIScrollView) {
        self.contentView = contentView
        self.parentController = parentController
        self.nodes = []
    }
    
    public weak var parentController: UIViewController?
    public weak var contentView: UIScrollView?
    
    public private(set) var nodes: Set<DisplayNode> = Set()
    public private(set) var links: Set<DisplayLink> = Set()
    
    public func add(displayNode: DisplayNode, shouldPositionRandomly: Bool = false) {
        if let contentView = contentView {
            displayNode.delegate = self
            contentView.addSubview(displayNode)
            nodes.insert(displayNode)
            
            if shouldPositionRandomly {
                self.positionRandomly(displayNode)
            }
        }
    }
    
    public func remove(displayNode: DisplayNode) {
        for link in displayNode.node.outgoingLinks + displayNode.node.incomingLinks {
            displayNode.node.remove(link: link)
        }
        
        displayNode.removeFromSuperview()
        displayNode.delegate = self
        nodes.remove(displayNode)
    }
    
    public func positionRandomly(_ displayNode: DisplayNode) {
        if let contentView = contentView {
            let halfWidth = contentView.bounds.width / 2.0
            let halfHeight = contentView.bounds.height / 2.0
            let origin = CGPoint(x: contentView.contentOffset.x + 200.0, y: contentView.contentOffset.y + 200.0)
            
            let randomXOffset = CGFloat(arc4random_uniform(UInt32(halfWidth)))
            let randomYOffset = CGFloat(arc4random_uniform(UInt32(halfHeight)))
            
            displayNode.center = CGPoint(x: origin.x + randomXOffset, y: origin.y + randomYOffset)
        }
    }
    
    fileprivate func refreshLinks(for node: DisplayNode) {
        for link in node.node.outgoingLinks {
            if let displayLink = displayLink(for: link) {
                displayLink.updatePath()
            }
        }
        
        for link in node.node.incomingLinks {
            if let displayLink = displayLink(for: link) {
                displayLink.updatePath()
            }
        }
    }
    
    fileprivate func bringToFront(for node: DisplayNode) {
        contentView?.bringSubviewToFront(node)
        
        for link in node.node.outgoingLinks {
            if let displayLink = displayLink(for: link) {
                contentView?.bringSubviewToFront(displayLink)
            }
        }
        
        for link in node.node.incomingLinks {
            if let displayLink = displayLink(for: link) {
                contentView?.bringSubviewToFront(displayLink)
            }
        }
    }
    
    fileprivate func displayLink(for link: Link) -> DisplayLink? {
        return links.first(where: { candidate -> Bool in
            return candidate.link == link
        })
    }
    
    fileprivate func sourceNode(for link: Link) -> DisplayNode? {
        return nodes.first(where: { candidate -> Bool in
            return candidate.node == link.source.node
        })
    }
    
    fileprivate func targetNode(for link: Link) -> DisplayNode? {
        return nodes.first(where: { candidate -> Bool in
            return candidate.node == link.target.node
        })
    }
    
    fileprivate typealias SocketSelection = (node: DisplayNode, socket: Socket, view: DisplaySocketView)
    
    fileprivate var selectedInputSocket: SocketSelection? = nil {
        didSet {
            oldValue?.view.selected = false
            selectedInputSocket?.view.selected = true
            createLinkIfNecessary()
        }
    }
    
    fileprivate var selectedOutputSocket: SocketSelection? = nil {
        didSet {
            oldValue?.view.selected = false
            selectedOutputSocket?.view.selected = true
            createLinkIfNecessary()
        }
    }
    
    @discardableResult
    private func createLinkIfNecessary() -> Bool {
        guard let input = selectedInputSocket, let output = selectedOutputSocket else { return false }
        let result = output.node.node.addLink(from: output.socket, to: input.node.node, targetSocket: input.socket)
        selectedOutputSocket = nil
        selectedInputSocket = nil
        return result
    }
}

extension DisplayContext: DisplayLinkDelegate {
    
    public func displayLinkTapped(_ link: DisplayLink, locationInView location: CGPoint) {
        print("Display Link Tapped: \(link)")
        
        let alertController = UIAlertController(title: "", message: "Select an Action", preferredStyle: .actionSheet)
        if let popoverController = alertController.popoverPresentationController {
            popoverController.sourceView = displayLink(for: link.link)
            popoverController.sourceRect = CGRect(x: location.x, y: location.y, width: 1.0, height: 1.0)
            popoverController.permittedArrowDirections = .any
        }
        
        let action = UIAlertAction(title: "Delete Link", style: .destructive) { [weak link] _ in
            guard let link = link else { return }
            link.link.source.node.remove(link: link.link)
        }
        
        alertController.addAction(action)
        
        parentController?.present(alertController, animated: true, completion: nil)
    }
    
    public func displayLinkChanged(_ link: DisplayLink) {
//        print("Display Link Changed: \(link)")
    }
}

extension DisplayContext: DisplayNodeDelegate {
    
    public typealias A = Double
    public typealias B = Double
    
    public func displayNodeDidChange(_ node: DisplayNode) {
        // print("Node Changed: \(node)")
        refreshLinks(for: node)
    }
    
    public func displayNode(_ node: DisplayNode, isDraggingWithOrigin origin: CGPoint) {
        // print("Is Dragging! \(origin)")
        refreshLinks(for: node)
    }
    
    public func displayNode(_ node: DisplayNode, willBeginDraggingFromOrigin origin: CGPoint) {
        // print("Begin Dragging...")
        bringToFront(for: node)
        refreshLinks(for: node)
    }
    
    public func displayNode(_ node: DisplayNode, didFinishDraggingToOrigin origin: CGPoint) {
        guard let contentView = contentView else { return }
        // print("Finished Dragging...")
        
        let maxX = node.frame.maxX
        let maxY = node.frame.maxY
        
        let width = contentView.contentSize.width - 200.0 < maxX ? (maxX + 200.0) : contentView.contentSize.width
        let height = contentView.contentSize.height - 200.0 < maxY ? (maxX + 200.0) : contentView.contentSize.height
        
        contentView.contentSize = CGSize(width: width, height: height)
        
        refreshLinks(for: node)
    }
    
    public func displayNodeDidDetectLongPress(_ node: DisplayNode) {
        let alertController = UIAlertController(title: node.node.title, message: "Select an Action", preferredStyle: .actionSheet)
        if let popoverController = alertController.popoverPresentationController {
            popoverController.sourceView = node
            popoverController.sourceRect = node.bounds
            popoverController.permittedArrowDirections = .any
        }
        
        let action = UIAlertAction(title: "Delete Node", style: .destructive) { [weak node, weak self] _ in
            guard let node = node else { return }
            self?.remove(displayNode: node)
        }
        
        alertController.addAction(action)
        
        parentController?.present(alertController, animated: true, completion: nil)
    }
    
    public func displayNode(_ displayNode: DisplayNode, addedOutgoingLink link: Link) {
        // Check if link already exists
        if displayLink(for: link) != nil { return }
        guard let contentView = contentView else { return }
        
        let sourceDisplayNode = sourceNode(for: link)
        let targetDisplayNode = targetNode(for: link)
        
        if let sourceView = sourceDisplayNode?.anchorView(for: link.source.socket),
           let targetView = targetDisplayNode?.anchorView(for: link.target.socket) {
            let displayLink = DisplayLink(link: link, contextView: contentView, sourceView: sourceView, targetView: targetView)
            displayLink.delegate = self
            links.insert(displayLink)
            contentView.addSubview(displayLink)
        }
        
        refreshLinks(for: displayNode)
    }
    
    public func displayNode(_ displayNode: DisplayNode, addedIncomingLink link: Link) {
        // Check if link already exists
        if displayLink(for: link) != nil { return }
        guard let contentView = contentView else { return }
        
        let sourceDisplayNode = sourceNode(for: link)
        let targetDisplayNode = targetNode(for: link)
        
        if let sourceView = sourceDisplayNode?.anchorView(for: link.source.socket),
            let targetView = targetDisplayNode?.anchorView(for: link.target.socket) {
            let displayLink = DisplayLink(link: link, contextView: contentView, sourceView: sourceView, targetView: targetView)
            displayLink.delegate = self
            links.insert(displayLink)
            contentView.addSubview(displayLink)
        }
        
        refreshLinks(for: displayNode)
    }
    
    public func displayNode(_ displayNode: DisplayNode, removedOutgoingLink link: Link) {
        guard let displayLink = displayLink(for: link) else { return }
        links.remove(displayLink)
        displayLink.removeFromSuperview()
        
        refreshLinks(for: displayNode)
    }
    
    public func displayNode(_ displayNode: DisplayNode, removedIncomingLink link: Link) {
        guard let displayLink = displayLink(for: link) else { return }
        links.remove(displayLink)
        displayLink.removeFromSuperview()
        
        refreshLinks(for: displayNode)
    }

    public func displayNode(_ displayNode: DisplayNode, tappedSocket socket: Socket, view: DisplaySocketView) {
        switch socket.kind {
        case .input:
            if selectedInputSocket?.node.node == displayNode.node {
                selectedInputSocket = nil
            } else if selectedOutputSocket?.node.node == displayNode.node {
                selectedInputSocket = nil
                selectedOutputSocket = nil
            } else {
                selectedInputSocket = SocketSelection(node: displayNode, socket: socket, view: view)
            }
            // print("Tapped INPUT Socket: \(socket) for view: \(view)")
        case .output:
            if selectedOutputSocket?.node.node == displayNode.node {
                selectedOutputSocket = nil
            } else if selectedInputSocket?.node.node == displayNode.node {
                selectedInputSocket = nil
                selectedOutputSocket = nil
            } else {
                selectedOutputSocket = SocketSelection(node: displayNode, socket: socket, view: view)
            }
            // print("Tapped OUTPUT Socket: \(socket) for view: \(view)")
        }
        
        refreshLinks(for: displayNode)
    }
}
