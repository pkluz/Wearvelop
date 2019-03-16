//
//  RipplingButton.swift
//
//  Created by Philip Kluz on 2018-12-05.
//  Copyright © 2018 Philip Kluz. All rights reserved.
//

import UIKit

@IBDesignable
public class RipplingButton: UIButton {
    
    @IBInspectable
    var shouldShowRipple: Bool = true
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if shouldShowRipple {
            clipsToBounds = true
            let center = touches.first?.location(in: self) ?? self.center
            RippleAnimator.ripple(view: self.rippleView, inView: self, origin: center)
        }
        
        super.touchesBegan(touches, with: event)
    }
    
    private var rippleView: UIView = {
        let view = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 300.0, height: 300.0))
        view.backgroundColor = UIColor.black.withAlphaComponent(0.1)
        view.layer.cornerRadius = 150.0
        view.alpha = 0.0
        return view
    }()
}
