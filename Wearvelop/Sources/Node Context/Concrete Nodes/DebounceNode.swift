//
//  DebounceNode.swift
//  Wearvelop
//
//  Created by Philip Kluz on 2019-02-16.
//  Copyright © 2019 Philip Kluz. All rights reserved.
//

import UIKit

/// Debounces the incoming values, deplaying their forwarding.
public class DebounceNode: Node {
    
    // MARK: - DebounceNode (Input)
    
    public let valueInput: Socket
    public let secondsInput: Socket
    
    // MARK: - DebounceNode (Output)
    
    public let output: Socket
    
    // MARK: - DebounceNode
    
    public init() {
        self.valueInput = Socket(title: "Input", kind: .input)
        self.secondsInput = Socket(title: "Seconds", kind: .input)
        self.output = Socket(title: "Output", kind: .output)
        
        super.init(title: "Debounce", inputs: [ self.valueInput, self.secondsInput ], outputs: [ self.output ])
        
        valueInput.socketValueChanged = inputValueChanged
        secondsInput.socketValueChanged = debounceSecondsValueChanged
    }
    
    deinit {
        timer?.invalidate()
        timer = nil
    }
    
    private var latestValue: (value: Value, date: Date)?
    private var timer: Timer? = nil
    
    public func inputValueChanged(from maybeOldValue: Value?, to maybeNewValue: Value?) {
        guard let newValue = maybeNewValue else {
            latestValue = nil
            return
        }
        
        latestValue = (newValue, Date())
    }
    
    public func debounceSecondsValueChanged(from maybeOldValue: Value?, to maybeNewValue: Value?) {
        guard let seconds = maybeNewValue?.unwrapAsDouble() else {
            timer?.invalidate()
            timer = nil
            return
        }
        
        resetTimer(seconds: seconds)
    }
    
    @objc private func debounceTimeLapsed(_ timer: Timer) {
        guard let value = latestValue, let seconds = secondsInput.value?.unwrapAsDouble() else { return }
        
        resetTimer(seconds: seconds)
        
        if Date().timeIntervalSince(value.date) > seconds {
            output.value = value.value
            latestValue = nil
        }
    }
    
    private func resetTimer(seconds: TimeInterval) {
        if let timer = timer {
            timer.invalidate()
        }
        
        timer = Timer.scheduledTimer(timeInterval: seconds,
                                     target: self,
                                     selector: #selector(debounceTimeLapsed(_:)),
                                     userInfo: nil,
                                     repeats: true)
    }
}
