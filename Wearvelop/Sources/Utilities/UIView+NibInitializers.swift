//
//  NibInitializers.swift
//  Wearvelop
//
//  Created by Philip Kluz on 2019-01-02.
//  Copyright © 2019 Philip Kluz. All rights reserved.
//

import UIKit

public extension UIView {
    
    public class func fromNib<T: UIView>(named: String? = nil, owner: Any? = nil, didLoad: (T) -> (Void) = {_ in }) -> T {
        return fromNib(named: named, bundle: Bundle.main, owner: owner, didLoad: didLoad)
    }
    
    public class func fromNib<T: UIView>(named: String? = nil, bundle: Bundle, owner: Any? = nil, didLoad: (T) -> (Void) = {_ in }) -> T {
        let view = bundle.loadNibNamed(named ?? String(describing: T.self), owner: owner, options: nil)!.first as! T
        didLoad(view)
        if let view = view as? NibConfigurable {
            view.configure()
        }
        return view
    }
}

public protocol NibConfigurable {
    func configure()
}
