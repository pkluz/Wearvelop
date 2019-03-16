//
//  DisplayLink.swift
//  Wearvelop
//
//  Created by Philip Kluz on 2019-02-06.
//  Copyright © 2019 Philip Kluz. All rights reserved.
//

import UIKit

public protocol DisplayLinkDelegate: class {
    func displayLinkChanged(_ link: DisplayLink)
    func displayLinkTapped(_ link: DisplayLink, locationInView: CGPoint)
}

public final class DisplayLink: UIView {
    
    // MARK: - NSObject
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIView
    
    public init(link: Link, contextView: UIView, sourceView: UIView, targetView: UIView) {
        self.sourceView = sourceView
        self.targetView = targetView
        self.contextView = contextView
        self.link = link
        super.init(frame: .zero)
        clipsToBounds = false
        backgroundColor = .clear
        isUserInteractionEnabled = true
        layer.addSublayer(shapeLayer)
        
        addGestureRecognizer(tapGestureRecognizer)
        
        updatePath()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        shapeLayer.path = path?.cgPath
        shapeLayer.frame = bounds
    }
    
    // MARK: - DisplayLink
    
    private lazy var shapeLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.path = path?.cgPath
        layer.strokeColor = UIColor.orange.cgColor
        layer.lineWidth = 5.0
        layer.fillColor = UIColor.clear.cgColor
        layer.lineCap = CAShapeLayerLineCap.round
        return layer
    }()
    
    private lazy var tapGestureRecognizer: UITapGestureRecognizer = {
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(didRecognizeTap(_:)))
        return recognizer
    }()
    
    @objc private func didRecognizeTap(_ recognizer: UITapGestureRecognizer) {
        let location = recognizer.location(in: self)
        // TODO: Note that this is technically an incorrect way to test for a hit on a line.
        //       It checks for a tap within the area defined by the bezier path, and not the line itself.
        //       It's good enough for now though.
        if let path = path, path.contains(location) {
            delegate?.displayLinkTapped(self, locationInView: location)
        }
    }
    
    public let link: Link
    public weak var contextView: UIView?
    public weak var delegate: DisplayLinkDelegate?
    
    private var path: UIBezierPath? {
        didSet {
            updateFrame()
            delegate?.displayLinkChanged(self)
        }
    }
    
    private weak var sourceView: UIView? {
        didSet { updatePath() }
    }
    
    private weak var targetView: UIView? {
        didSet { updatePath() }
    }
    
    public func updatePath() {
        updateFrame()
        
        guard let sourceView = sourceView, let targetView = targetView else { return }

        let sc = sourceView.convert(CGPoint(x: sourceView.bounds.midX, y: sourceView.bounds.midY), to: self)
        let tc = targetView.convert(CGPoint(x: targetView.bounds.midX, y: targetView.bounds.midY), to: self)
        var sccp = sc
        var tccp = tc

        let d = abs(tccp.x - sccp.x) / 1.2
        sccp.x = sccp.x + d
        tccp.x = tccp.x - d

        let path = UIBezierPath()
        path.move(to: sc)
        path.addCurve(to: tc, controlPoint1: sccp, controlPoint2: tccp)

        self.path = path
    }
    
    public func updateFrame() {
        guard let sourceView = sourceView, let targetView = targetView else { return }
        
        let sf = sourceView.convert(sourceView.bounds, to: contextView)
        let tf = targetView.convert(targetView.bounds, to: contextView)
        
        frame = CGRect(x: min(sf.origin.x, tf.origin.x),
                       y: min(sf.origin.y, tf.origin.y),
                       width: abs(sf.origin.x - tf.origin.x),
                       height: abs(sf.origin.y - tf.origin.y))
    }
    
    public func deletePath() {
        path = nil
    }
}
