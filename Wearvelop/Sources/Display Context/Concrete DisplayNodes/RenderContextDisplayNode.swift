//
//  RenderContextDisplayNode.swift
//  Wearvelop
//
//  Created by Philip Kluz on 2019-03-14.
//  Copyright © 2019 Philip Kluz. All rights reserved.
//

import UIKit

/// `RenderContextDisplayNode` is a customized version of `RenderContextNode` for displaying a renderable context.
public class RenderContextDisplayNode: DisplayNode {
    
    // MARK: - NSObject
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIView
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        renderView.frame = frameForRenderView(width: width, height: height, container: bounds)
    }
    
    // MARK: - NodeDelegate
    
    public override func nodeChanged(_ node: Node) {
        super.nodeChanged(node)
        
        guard let node = node as? RenderContextNode else { return }
        
        renderView.backgroundColor = node.backgroundColorInput.value?.unwrapAsColor()?.systemColor ?? UIColor.white
        
        guard let width = node.widthInput.value?.unwrapAsDouble(),
              let height = node.heightInput.value?.unwrapAsDouble() else { return }
        
        self.width = width
        self.height = height
        
        UIView.animate(withDuration: 0.1) {
            self.frame = RenderContextDisplayNode.resizedFrame(for: node, currentFrame: self.frame, width: width, height: height)
        }

        renderView.subviews.forEach { view in
            view.removeFromSuperview()
        }
        
        if let subviews = node.viewsInput.value?.unwrapAsViewValueArray(), !subviews.isEmpty {
            for viewValue in subviews {
                let view = viewValue.toView()
                renderView.addSubview(view)
            }
        } else if let subviewValue = node.viewsInput.value?.unwrapAsViewValue() {
            let view = subviewValue.toView()
            renderView.addSubview(view)
        }
    }
    
    // MARK: - RenderContextDisplayNode
    
    public enum Constants {
        public static let defaultWidth: Double = 300.0
        public static let defaultHeight: Double = 300.0
    }
    
    public var width: Double = Constants.defaultWidth
    public var height: Double = Constants.defaultHeight
    
    public convenience init(width: Double = Constants.defaultWidth, height: Double = Constants.defaultHeight) {
        let node = RenderContextNode(width: width, height: height)
        let frame = RenderContextDisplayNode.resizedFrame(for: node, currentFrame: .zero)
        self.init(frame: frame, node: node)
        self.width = width
        self.height = height
    }
    
    public init(frame: CGRect, node: RenderContextNode) {
        super.init(frame: frame, node: node)
        node.delegate = self
        addSubview(renderView)
        nodeChanged(node)
    }
    
    public static func resizedFrame(for node: Node, currentFrame: CGRect, width: Double = Constants.defaultWidth, height: Double = Constants.defaultHeight) -> CGRect {
        var frame = DisplayNode.frame(for: node)
        frame.origin.x = currentFrame.origin.x
        frame.origin.y = currentFrame.origin.y
        frame.size.width = max(frame.width, CGFloat(width) + (DisplayNodeConstants.socketLeadingTrailingSpacing * 2.0))
        frame.size.height = frame.height + CGFloat(height) + (DisplayNodeConstants.socketLeadingTrailingSpacing * 2.0)
        return frame
    }
    
    private func frameForRenderView(width: Double, height: Double, container: CGRect) -> CGRect {
        let lastSocketFrame = frameForSocket(atIndex: max(max(socketInputViews.count, socketOutputViews.count) - 1, 0), horizontalOffset: 0.0, verticalOffset: titleDivider.frame.maxY + DisplayNodeConstants.socketTopBottomSpacing)
        
        let x: CGFloat = {
            let renderWidth = CGFloat(width) + (DisplayNodeConstants.socketLeadingTrailingSpacing * 2)
            
            if container.width > renderWidth {
                return (container.width / 2.0) - (renderWidth / 2.0) + DisplayNodeConstants.socketLeadingTrailingSpacing
            } else {
                return DisplayNodeConstants.socketLeadingTrailingSpacing
            }
        }()
        
        return CGRect(x: x,
                      y: lastSocketFrame.maxY + (DisplayNodeConstants.socketTopBottomSpacing * 2),
                      width: CGFloat(width),
                      height: CGFloat(height))
    }
    
    public let renderView: UIView = {
        let view = UIView()
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 6.0
        view.layer.borderColor = Color(red: 0.93, green: 0.93, blue: 0.93).cgColor
        view.layer.borderWidth = 3.0
        return view
    }()
}
