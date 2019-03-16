//
//  ThrottleNode.swift
//  Wearvelop
//
//  Created by Philip Kluz on 2019-02-15.
//  Copyright © 2019 Philip Kluz. All rights reserved.
//

import UIKit

public class ThrottleNode: Node {
    
    // MARK: - ThrottleNode (Input)
    
    public let valueInput: Socket
    public let secondsInput: Socket
    
    // MARK: - ThrottleNode (Output)
    
    public let output: Socket
    
    // MARK: - ThrottleNode
    
    public init() {
        self.valueInput = Socket(title: "Input", kind: .input)
        self.secondsInput = Socket(title: "Seconds", kind: .input)
        self.output = Socket(title: "Output", kind: .output)
        
        super.init(title: "Throttle", inputs: [ self.valueInput, self.secondsInput ], outputs: [ self.output ])
        
        valueInput.socketValueChanged = inputValueChanged
        secondsInput.socketValueChanged = throttleSecondsValueChanged
    }
    
    private var hasChanges: Bool = false
    private var latestValue: Value? {
        didSet {
            if latestValue != oldValue {
                hasChanges = true
            }
        }
    }
    private var timer: Timer? = nil
    
    public func inputValueChanged(from maybeOldValue: Value?, to maybeNewValue: Value?) {
        latestValue = maybeNewValue
    }
    
    public func throttleSecondsValueChanged(from maybeOldValue: Value?, to maybeNewValue: Value?) {
        guard let seconds = maybeNewValue?.unwrapAsDouble() else {
            timer?.invalidate()
            timer = nil
            return
        }
        
        timer = Timer.scheduledTimer(timeInterval: seconds,
                                     target: self,
                                     selector: #selector(throttleTimeLapsed(_:)),
                                     userInfo: nil,
                                     repeats: true)
    }
    
    @objc private func throttleTimeLapsed(_ timer: Timer) {
        if !hasChanges { return }
        hasChanges = false
        output.value = latestValue
    }
}
