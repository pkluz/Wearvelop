//
//  CGPoint+Distance.swift
//  Wearvelop
//
//  Created by Philip Kluz on 2019-01-07.
//  Copyright © 2019 Philip Kluz. All rights reserved.
//

import UIKit

extension CGPoint {
    
    public func distance(to target: CGPoint) -> CGFloat {
        let xDist = x - target.x
        let yDist = y - target.y
        return CGFloat(sqrt(xDist * xDist + yDist * yDist))
    }
}
