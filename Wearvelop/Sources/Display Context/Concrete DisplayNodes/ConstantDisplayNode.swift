//
//  ConstantDisplayNode.swift
//  Wearvelop
//
//  Created by Philip Kluz on 2019-01-14.
//  Copyright © 2019 Philip Kluz. All rights reserved.
//

import UIKit

/// `ChartDisplayNode` is a customized version of `DisplayNode` because
/// it requires a larger frame and some additional subviews to work (in case of larger constants).
public class ConstantDisplayNode: DisplayNode {
    
    // MARK: - NSObject
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIView
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        if displayView.superview != nil {
            displayView.frame = frameForDisplayView()
        }
    }
    
    // MARK: - ConstantDisplayNode
    
    public init(value: Value) {
        let node = ConstantNode(value: value)
        
        switch value {
        case .string, .array, .map:
            var frame = DisplayNode.frame(for: node)
            frame.size.width = max(frame.width, 280.0)
            frame.size.height = max(frame.height, 174.0)
            super.init(frame: frame, node: node)
            node.delegate = self
            addSubview(displayView)
            displayView.text = value.description
        default:
            super.init(node: node)
        }
    }
    
    private func frameForDisplayView() -> CGRect {
        let lastSocketFrame = frameForSocket(atIndex: max(max(socketInputViews.count, socketOutputViews.count) - 1, 0), horizontalOffset: 0.0, verticalOffset: titleDivider.frame.maxY + DisplayNodeConstants.socketTopBottomSpacing)
        return CGRect(x: DisplayNodeConstants.socketLeadingTrailingSpacing,
                      y: lastSocketFrame.maxY + DisplayNodeConstants.socketTopBottomSpacing,
                      width: bounds.width - (DisplayNodeConstants.socketLeadingTrailingSpacing * 2.0),
                      height: bounds.height - lastSocketFrame.maxY - (DisplayNodeConstants.socketTopBottomSpacing * 2.0))
    }
    
    public let displayView: UITextView = {
        let view = UITextView(frame: .zero)
        view.backgroundColor = Color(red: 0.93, green: 0.93, blue: 0.93).systemColor
        view.layer.cornerRadius = 6.0
        view.isEditable = false
        view.isSelectable = false
        view.font = UIFont.monospacedDigitSystemFont(ofSize: 14.0, weight: .medium)
        view.textColor = Color(red: 0.35, green: 0.35, blue: 0.35).systemColor
        return view
    }()
}
