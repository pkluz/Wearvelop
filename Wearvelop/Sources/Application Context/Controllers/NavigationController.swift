//
//  NavigationController.swift
//  Annotator
//
//  Created by Philip Kluz on 2019-01-04.
//  Copyright © 2019 Philip Kluz. All rights reserved.
//

import UIKit

public final class NaivgationController: UINavigationController {
    
    public override var shouldAutorotate: Bool {
        return false
    }
    
    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
}
