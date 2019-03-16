//
//  DisplayNode.swift
//  Wearvelop
//
//  Created by Philip Kluz on 2019-01-10.
//  Copyright © 2019 Philip Kluz. All rights reserved.
//

import UIKit

internal let kDispalyNodeTitleAttributes: [NSAttributedString.Key: Any] = [
    NSAttributedString.Key.foregroundColor: UIColor.darkGray,
    NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: DisplayNodeConstants.titleFontSize)
]

internal let kDispalyNodeSocketAttributes: [NSAttributedString.Key: Any] = [
    NSAttributedString.Key.foregroundColor: UIColor.darkGray,
    NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: DisplayNodeConstants.socketFontSize)
]

public protocol DisplayNodeDelegate: class {
    func displayNode(_ node: DisplayNode, willBeginDraggingFromOrigin: CGPoint)
    func displayNode(_ node: DisplayNode, isDraggingWithOrigin: CGPoint)
    func displayNode(_ node: DisplayNode, didFinishDraggingToOrigin: CGPoint)
    func displayNodeDidChange(_ node: DisplayNode)
    func displayNodeDidDetectLongPress(_ node: DisplayNode)
    func displayNode(_ displayNode: DisplayNode, addedOutgoingLink: Link)
    func displayNode(_ displayNode: DisplayNode, addedIncomingLink: Link)
    func displayNode(_ displayNode: DisplayNode, removedOutgoingLink: Link)
    func displayNode(_ displayNode: DisplayNode, removedIncomingLink: Link)
    func displayNode(_ displayNode: DisplayNode, tappedSocket: Socket, view: DisplaySocketView)
}

internal struct DisplayNodeConstants {
    static let titleFontSize: CGFloat = 16.0
    static let titleLabelHeight: CGFloat = 36.0
    static let socketFontSize: CGFloat = 12.0
    static let socketHeight: CGFloat = 21.0
    static let socketWidth: CGFloat = 100.0
    static let socketTopBottomSpacing: CGFloat = 5.0
    static let socketLeadingTrailingSpacing: CGFloat = 8.0
    static let inputOutputSpacing: CGFloat = 40.0
    static let cornerRadius: CGFloat = 8.0
}

/// This class defines the generic rendering behavior and layout of a node
/// as visualized in a rendering context.
///
/// You can pass any type of `Node` to be displayed within, or create a subclass
/// to customize rendering behavior.
public class DisplayNode: UIView, NodeDelegate {
    
    // MARK: - NSObject
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIView
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        titleLabel.frame = titleLabelFrame(for: node.title, containerWidth: bounds.width)
        titleDivider.frame = titleDividerFrame(given: titleLabel.frame)
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = .zero
        layer.shadowOpacity = 0.25
        layer.shadowRadius = 12.0
        layer.cornerRadius = DisplayNodeConstants.cornerRadius
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: 8.0).cgPath
        
        for view in socketInputViews {
            view.frame = frameForSocket(atIndex: view.tag,
                                        horizontalOffset: DisplayNodeConstants.socketLeadingTrailingSpacing,
                                        verticalOffset: titleDivider.frame.maxY + DisplayNodeConstants.socketTopBottomSpacing)
        }
        
        for view in socketOutputViews {
            view.frame = frameForSocket(atIndex: view.tag,
                                        horizontalOffset: bounds.width - DisplayNodeConstants.socketWidth - DisplayNodeConstants.socketLeadingTrailingSpacing,
                                        verticalOffset: titleDivider.frame.maxY + DisplayNodeConstants.socketTopBottomSpacing)
        }
    }
    
    private var touchOrigin: CGPoint?
    private var touchStart: Date? = nil
    private var registeredSignificantMovement: Bool = false
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        isDragging = true
        delegate?.displayNode(self, willBeginDraggingFromOrigin: center)
        
        if let touch = touches.first {
            touchOrigin = touch.location(in: self.superview)
            touchStart = Date()
            registeredSignificantMovement = false
        }
    }
    
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        
        if let touch = touches.first  {
            let p1 = touch.location(in: self.superview)
            let p0 = touch.previousLocation(in: self.superview)
            let translation = CGPoint(x: p1.x - p0.x, y: p1.y - p0.y)
            center = CGPoint(x: center.x + translation.x, y: center.y + translation.y)
            delegate?.displayNode(self, isDraggingWithOrigin: center)
            
            if (touchOrigin?.distance(to: p1) ?? 0) > 20.0 {
                registeredSignificantMovement = true
            }
        }
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        isDragging = false
        delegate?.displayNode(self, didFinishDraggingToOrigin: center)
        
        handleLongPressIfNeeded()
    }
    
    public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        isDragging = false
        delegate?.displayNode(self, didFinishDraggingToOrigin: center)
        
        handleLongPressIfNeeded()
    }
    
    private func handleLongPressIfNeeded() {
        if let start = touchStart, !registeredSignificantMovement && Date().timeIntervalSince(start) > 0.33 {
            delegate?.displayNodeDidDetectLongPress(self)
        } else {
            touchStart = nil
            touchOrigin = nil
            registeredSignificantMovement = false
        }
    }
    
    // MARK: - DispalyNode
    
    public weak var delegate: DisplayNodeDelegate?
    
    public init(node: Node) {
        self.node = node
        super.init(frame: DisplayNode.frame(for: node))
        node.delegate = self
        backgroundColor = .white
        
        addSubview(titleLabel)
        addSubview(titleDivider)
        
        for view in socketInputViews {
            addSubview(view)
        }
        
        for view in socketOutputViews {
            addSubview(view)
        }
    }
    
    public init(frame: CGRect, node: Node) {
        self.node = node
        super.init(frame: frame)
        backgroundColor = .white
        
        addSubview(titleLabel)
        addSubview(titleDivider)
        
        for view in socketInputViews {
            addSubview(view)
        }
        
        for view in socketOutputViews {
            addSubview(view)
        }
    }
    
    internal var isDragging: Bool = false {
        didSet {
            let scale: CGFloat = isDragging ? 1.1 : 1.0
            
            UIView.animate(withDuration: 0.05, delay: 0.0, options: [.beginFromCurrentState, .curveEaseIn], animations: {
                self.layer.transform = CATransform3DMakeScale(scale, scale, 1.0)
                self.layer.shadowOpacity = self.isDragging ? 0.15 : 0.25
                self.layer.shadowRadius = self.isDragging ? 16.0 : 12.0
            }, completion: nil)
        }
    }

    internal static func frame(for node: Node) -> CGRect {
        let size = DisplayNode.size(for: node)
        return CGRect(x: 20.0, y: 20.0, width: size.width, height: size.height)
    }
    
    internal static func size(for node: Node) -> CGSize {
        let titleSize = (node.title as NSString).size(withAttributes: kDispalyNodeTitleAttributes)
        let titleWidth: CGFloat = 20.0 + titleSize.width + 20.0
        let titleHeight: CGFloat = DisplayNodeConstants.titleLabelHeight
        
        let socketCount = max(node.outputs.count, node.inputs.count)
        let socketHeight = CGFloat(socketCount) * (DisplayNodeConstants.socketHeight + DisplayNodeConstants.socketTopBottomSpacing)
        
        let width = max(titleWidth, DisplayNodeConstants.socketWidth + DisplayNodeConstants.inputOutputSpacing + DisplayNodeConstants.socketWidth)
        let height = titleHeight + DisplayNodeConstants.socketTopBottomSpacing + socketHeight
        
        return CGSize(width: width, height: height)
    }
    
    internal func titleLabelFrame(for title: String, containerWidth: CGFloat) -> CGRect {
        let titleSize = (node.title as NSString).size(withAttributes: kDispalyNodeTitleAttributes)
        let titleWidth: CGFloat = 20.0 + titleSize.width + 20.0
        let titleHeight: CGFloat = DisplayNodeConstants.titleLabelHeight
        return CGRect(x: 0.0, y: 0.0, width: max(titleWidth, containerWidth), height: titleHeight)
    }
    
    internal func titleDividerFrame(given titleFrame: CGRect) -> CGRect {
        return CGRect(x: titleFrame.minX, y: titleFrame.maxY, width: titleFrame.width, height: 1.0)
    }
    
    internal func frameForSocket(atIndex index: Int, horizontalOffset: CGFloat = 0.0, verticalOffset: CGFloat = 0.0) -> CGRect {
        return CGRect(x: horizontalOffset,
                      y: verticalOffset + (CGFloat(index) * DisplayNodeConstants.socketHeight) + (CGFloat(index) * DisplayNodeConstants.socketTopBottomSpacing),
                      width: DisplayNodeConstants.socketWidth,
                      height: DisplayNodeConstants.socketHeight)
    }
    
    internal lazy var socketInputViews: [DisplaySocketView] = {
        return node.inputs.enumerated().map { (offset: Int, element: Socket) -> DisplaySocketView in
            return socketView(for: element, index: offset)
        }
    }()
    
    internal lazy var socketOutputViews: [DisplaySocketView] = {
        return node.outputs.enumerated().map { (offset: Int, element: Socket) -> DisplaySocketView in
            return socketView(for: element, index: offset)
        }
    }()
    
    internal lazy var titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.numberOfLines = 0
        
        var attributes = kDispalyNodeTitleAttributes
        attributes[.paragraphStyle] = {
            let style = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
            style.alignment = .center
            return style
        }()
        label.backgroundColor = .clear
        label.attributedText = NSAttributedString(string: node.title, attributes: attributes)
        return label
    }()
    
    public func anchorView(for socket: Socket) -> UIView? {
        if socket.kind == .input {
            if !node.inputs.contains(socket) {
                return nil
            }
            
            if let index = node.inputs.firstIndex(of: socket) {
                return socketInputViews[safe: index]?.socketCircle
            }
            
            return nil
        }
        
        if !node.outputs.contains(socket) {
            return nil
        }
        
        if let index = node.outputs.firstIndex(of: socket) {
            return socketOutputViews[safe: index]?.socketCircle
        }
        
        return nil
    }
    
    internal func socketView(for socket: Socket, index: Int) -> DisplaySocketView {
        let view = DisplaySocketView(socket: socket, size: CGSize(width: DisplayNodeConstants.socketWidth, height: DisplayNodeConstants.socketHeight))
        view.tag = index
        view.backgroundColor = .clear
        view.tapAction = { [weak self] view in
            self?.tapped(socket: socket, view: view, index: index)
        }
        return view
    }
    
    private func tapped(socket: Socket, view: DisplaySocketView, index: Int) {
        delegate?.displayNode(self, tappedSocket: socket, view: view)
    }
    
    internal lazy var titleDivider: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = UIColor(white: 0.0, alpha: 0.1)
        return view
    }()
    
    public let node: Node
    
    // MARK: - NodeDelegate
    
    public func node(_ node: Node, addedOutgoingLink link: Link) {
        delegate?.displayNode(self, addedOutgoingLink: link)
    }
    
    public func node(_ node: Node, addedIncomingLink link: Link) {
        delegate?.displayNode(self, addedIncomingLink: link)
    }
    
    public func node(_ node: Node, removedOutgoingLink link: Link) {
        delegate?.displayNode(self, removedOutgoingLink: link)
    }
    
    public func node(_ node: Node, removedIncomingLink link: Link) {
        delegate?.displayNode(self, removedIncomingLink: link)
    }
    
    public func nodeChanged(_: Node) {
        delegate?.displayNodeDidChange(self)
    }
}
