//
//  UIViewDisplayNode.swift
//  Wearvelop
//
//  Created by Philip Kluz on 2019-03-21.
//  Copyright © 2019 Philip Kluz. All rights reserved.
//

import UIKit

/// `UIViewDisplayNode` is a customized version of `UIViewNode` for displaying renderable context.
public class UIViewDisplayNode: RenderContextDisplayNode {
    
    public convenience init(width: Double, height: Double) {
        self.init(x: 0.0, y: 0.0, width: width, height: height)
    }
    
    public init(x: Double = 0.0,
                y: Double = 0.0,
                width: Double = 200.0,
                height: Double = 100.0) {
        let node = UIViewNode(x: 0.0, y: 0.0, width: width, height: height, title: nil, extraInputs: [], extraOutputs: [])
        let frame = UIViewDisplayNode.resizedFrame(for: node, currentFrame: .zero, width: width, height: height)
        super.init(frame: frame, node: node)
        renderView.layer.borderWidth = 0.0
    }
    
    public init(node: UIViewNode, preferredWidth width: Double, preferredHeight height: Double) {
        let frame = UIViewDisplayNode.resizedFrame(for: node, currentFrame: .zero, width: width, height: height)
        super.init(frame: frame, node: node)
        renderView.layer.borderWidth = 0.0
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func nodeChanged(_ node: Node) {
        super.nodeChanged(node)
        
        renderView.backgroundColor = .white
        
        guard let viewValue = (node as? UIViewNode)?.viewValue else { return }
        let view = viewValue.toView()

        renderView.subviews.forEach { $0.removeFromSuperview() }

        view.frame = CGRect(x: 0.0, y: 0.0, width: view.frame.width, height: view.frame.height)
        renderView.addSubview(view)
    }
    
    private func viewChanged(_ view: UIView) {
        nodeChanged(node)
    }
}
