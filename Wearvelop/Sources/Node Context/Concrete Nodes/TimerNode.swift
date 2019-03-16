//
//  ThrottleNode.swift
//  Wearvelop
//
//  Created by Philip Kluz on 2019-02-06.
//  Copyright © 2019 Philip Kluz. All rights reserved.
//

import UIKit

// Node that sends a signal every x seconds.
public class TimerNode: Node {
    
    // MARK: - ThrottleNode (Output)
    
    public let output: Socket
    
    // MARK: - ThrottleNode
    
    public init(interval: TimeInterval) {
        self.output = Socket(title: "Driver", kind: .output)
        
        super.init(title: "Timer \(String(format:"%.2f", interval))", inputs: [ ], outputs: [ self.output ])
        
        self.timer = Timer.scheduledTimer(timeInterval: interval,
                                          target: self,
                                          selector: #selector(tick(_:)),
                                          userInfo: nil,
                                          repeats: true)
        
    }
    
    deinit {
        timer.invalidate()
        timer = nil
    }
    
    private var timer: Timer!
    
    @objc private func tick(_ timer: Timer) {
        self.output.value = .bool(true)
    }
}
