//
//  DisplaySocketView.swift
//  Wearvelop
//
//  Created by Philip Kluz on 2019-02-05.
//  Copyright © 2019 Philip Kluz. All rights reserved.
//

import UIKit

fileprivate struct Constants {
    static let socketFontSize: CGFloat = 13.0
    static let socketDiameter: CGFloat = 14.0
}

/// Models the a socket that can be connected to.
///
/// Input:
/// +==============================+
/// | (x) SOCKET NAME         ...  |
/// +==============================+
///
///
/// Output:
/// +==============================+
/// | ...          SOCKET NAME (x) |
/// +==============================+
public final class DisplaySocketView: UIView {
    
    // MARK: - UIView
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        if kind == .input {
            socketCircle.frame = CGRect(x: 0.0, y: bounds.midY - (Constants.socketDiameter / 2.0), width: Constants.socketDiameter, height: Constants.socketDiameter)
            titleLabel.frame = CGRect(x: socketCircle.frame.maxX + 5.0, y: 0.0, width: bounds.width - 20.0, height: bounds.height)
        } else {
            titleLabel.frame = CGRect(x: 0.0, y: 0.0, width: bounds.width - 18.0, height: bounds.height)
            socketCircle.frame = CGRect(x: titleLabel.frame.maxX + 6.0, y: bounds.midY - (Constants.socketDiameter / 2.0), width: Constants.socketDiameter, height: Constants.socketDiameter)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - DisplaySocketView
    
    private let title: String
    private let kind: Socket.Kind
    public var tapAction: (DisplaySocketView) -> Void = { _ in }
    
    public init(socket: Socket, size: CGSize) {
        self.title = socket.title
        self.kind = socket.kind
        
        super.init(frame: CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height))
        
        addSubview(titleLabel)
        addSubview(socketCircle)
        addGestureRecognizer(tapGestureRecognizer)
    }
    
    public var selected: Bool = false {
        didSet {
            socketCircle.layer.borderColor = selected ? UIColor.red.cgColor : UIColor.darkGray.cgColor
            socketCircle.layer.borderWidth = 3.0
            socketCircle.backgroundColor = selected ? UIColor.red.withAlphaComponent(0.2) : .clear
            titleLabel.attributedText = attributedTitle(with: title, color: selected ? UIColor.red : nil)
        }
    }
    
    public lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.backgroundColor = .clear
        label.attributedText = attributedTitle(with: title)
        return label
    }()
    
    private func attributedTitle(with text: String, color: UIColor? = nil) -> NSAttributedString {
        var attributes = [
            NSAttributedString.Key.foregroundColor: color ?? .darkGray,
            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: Constants.socketFontSize)
        ]
        attributes[.paragraphStyle] = {
            let style = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
            style.alignment = self.kind == .input ? .left : .right
            return style
        }()
        return NSAttributedString(string: text, attributes: attributes)
    }
    
    public lazy var socketCircle: UIView = {
        let view = UIView(frame: CGRect(x: 0.0, y: bounds.midY - (Constants.socketDiameter / 2.0), width: Constants.socketDiameter, height: Constants.socketDiameter))
        view.backgroundColor = .white
        view.layer.cornerRadius = Constants.socketDiameter / 2.0
        view.layer.masksToBounds = true
        view.layer.borderColor = UIColor.darkGray.cgColor
        view.layer.borderWidth = 3.0
        return view
    }()
    
    private lazy var tapGestureRecognizer: UITapGestureRecognizer = {
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(didRecognizeTap(_:)))
        return recognizer
    }()
    
    @objc private func didRecognizeTap(_ recognizer: UITapGestureRecognizer) {
        tapAction(self)
    }
}
