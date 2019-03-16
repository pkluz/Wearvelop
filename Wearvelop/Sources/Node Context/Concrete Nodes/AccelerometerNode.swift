//
//  AccelerometerNode.swift
//  Wearvelop
//
//  Created by Philip Kluz on 2019-01-12.
//  Copyright © 2019 Philip Kluz. All rights reserved.
//

import UIKit
import CoreMotion

/// Node providing access to continously delivered X, Y, Z, and gX, gY, gZ values provided by the device's internal accelerometer.
public class AccelerometerNode: Node {
    
    // MARK: - AccelerometerNode (Input)
    
    public let frequencyInput: Socket
    
    // MARK: - AccelerometerNode (Output)
    
    // Acceleration
    public let xOutput: Socket
    public let yOutput: Socket
    public let zOutput: Socket
    
    // Gravity
    public let gxOutput: Socket
    public let gyOutput: Socket
    public let gzOutput: Socket
    
    // MARK: - AccelerometerNode
    
    public struct Constants {
        public static let defaultSampleRate: Double = 60.0
    }
    
    public init(samplingFrequenctInHertz frequency: Double = Constants.defaultSampleRate,
                xSocket: Socket = Socket(title: "X", kind: .output),
                ySocket: Socket = Socket(title: "Y", kind: .output),
                zSocket: Socket = Socket(title: "Z", kind: .output),
                gxSocket: Socket = Socket(title: "gravX", kind: .output),
                gySocket: Socket = Socket(title: "gravY", kind: .output),
                gzSocket: Socket = Socket(title: "gravZ", kind: .output)) {
        self.xOutput = xSocket
        self.yOutput = ySocket
        self.zOutput = zSocket
        
        self.gxOutput = gxSocket
        self.gyOutput = gySocket
        self.gzOutput = gzSocket
        
        self.frequencyInput = Socket(title: "Hz", kind: .input, value: .double(frequency))
        
        super.init(title: "Accelerometer",
                   inputs: [ self.frequencyInput ],
                   outputs: [ self.xOutput, self.yOutput, self.zOutput, self.gxOutput, self.gyOutput, self.gzOutput ])
        
        self.frequencyInput.socketValueChanged = samplingRateChanged
        self.frequencyInput.value = .double(frequency)
    }
    
    deinit {
        timer?.invalidate()
        timer = nil
    }
    
    private let motion = CMMotionManager()
    private var timer: Timer? = nil
    
    private func samplingRateChanged(from maybeOldValue: Value?, to maybeNewValue: Value?) {
        guard let newValue = maybeNewValue else {
            stopMotion()
            return
        }
        
        let frequency = newValue.unwrapAsDouble() ?? Constants.defaultSampleRate
        startMotion(frequency: frequency)
    }
    
    private func startMotion(frequency: Double) {
        if self.motion.isDeviceMotionAvailable {
            if self.motion.isDeviceMotionActive || (timer?.isValid ?? false) {
                stopMotion()
            }
            
            self.motion.deviceMotionUpdateInterval = 1.0 / frequency  // 60 Hz
            self.motion.startDeviceMotionUpdates(using: .xArbitraryCorrectedZVertical)
            
            self.timer = Timer.scheduledTimer(timeInterval: 1.0 / frequency,
                                              target: self,
                                              selector: #selector(receivedMotionData(_:)),
                                              userInfo: nil,
                                              repeats: true)
        }
    }
    
    private func stopMotion() {
        if self.motion.isDeviceMotionActive {
            self.motion.stopDeviceMotionUpdates()
        }
        
        self.timer?.invalidate()
        self.timer = nil
    }

    @objc private func receivedMotionData(_ timer: Timer) {
        if let data = self.motion.deviceMotion?.userAcceleration {
            self.xOutput.value = .double(data.x)
            self.yOutput.value = .double(data.y)
            self.zOutput.value = .double(data.z)
        }
        
        if let data = self.motion.deviceMotion?.gravity {
            self.gxOutput.value = .double(data.x)
            self.gyOutput.value = .double(data.y)
            self.gzOutput.value = .double(data.z)
        }
    }
}
