//
//  Rippling.swift
//
//  Created by Philip Kluz on 2018-12-05.
//  Copyright © 2018 Philip Kluz. All rights reserved.
//

import UIKit

public protocol Rippling {
    var ripplesOnTouch: Bool { get set }
}

public struct RippleAnimator {
    
    public static func ripple(view rippleView: UIView, inView host: UIView, origin: CGPoint) {
        rippleView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        rippleView.alpha = 1.0
        rippleView.center = origin
        host.addSubview(rippleView)
        
        UIView.animate(withDuration: 0.65,
                       delay: 0.0,
                       options: .curveEaseInOut,
                       animations: {
                        rippleView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                        rippleView.alpha = 0.0
        }) { (finished) in
            rippleView.transform = .identity
            rippleView.removeFromSuperview()
        }
    }
}

extension UIView: Rippling {
    
    public var ripplesOnTouch: Bool {
        get {
            return gestureRecognizers?.contains(rippleTapRecognizer) ?? false
        }
        set (ripples) {
            if ripples {
                addGestureRecognizer(rippleTapRecognizer)
                clipsToBounds = true
            } else {
                if gestureRecognizers?.contains(rippleTapRecognizer) ?? false {
                    removeGestureRecognizer(rippleTapRecognizer)
                }
            }
        }
    }
    
    private static let _rippleView = ObjectAssociation<UIView>()
    
    private var rippleView: UIView {
        get {
            guard let view = UIView._rippleView[self] else {
                self.rippleView = {
                    let view = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 300.0, height: 300.0))
                    view.backgroundColor = UIColor.black.withAlphaComponent(0.03)
                    view.layer.cornerRadius = 150.0
                    view.alpha = 0.0
                    return view
                }()
                
                return self.rippleView
            }
            return view
        }
        set {
            UIView._rippleView[self] = newValue
        }
    }
    
    private static let _rippleTapRecognizer = ObjectAssociation<UITapGestureRecognizer>()
    
    private var rippleTapRecognizer: UITapGestureRecognizer {
        get {
            guard let recognizer = UIView._rippleTapRecognizer[self] else {
                self.rippleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(_didRecognizeRippleTap(recognizer:)))
                return self.rippleTapRecognizer
            }
            return recognizer
        }
        set {
            UIView._rippleTapRecognizer[self] = newValue
        }
    }
    
    @objc private func _didRecognizeRippleTap(recognizer: UITapGestureRecognizer) {
        let center = recognizer.location(in: self)
        RippleAnimator.ripple(view: self.rippleView, inView: self, origin: center)
    }
}
