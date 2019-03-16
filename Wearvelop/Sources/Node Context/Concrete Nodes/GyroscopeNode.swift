//
//  GyroscopeNode.swift
//  Wearvelop
//
//  Created by Philip Kluz on 2019-02-22.
//  Copyright © 2019 Philip Kluz. All rights reserved.
//

import UIKit
import CoreMotion

/// Node providing access to continously delivered X, Y, Z, as well as pitch, roll, and yar rotational values provided by the device's internal gyroscope.
public class GyroscopeNode: Node {
    
    // MARK: - GyroscopeNode (Input)
    
    public let frequencyInput: Socket
    
    // MARK: - GyroscopeNode (Output)
    
    public let pitchOutput: Socket
    public let rollOutput: Socket
    public let yawOutput: Socket
    
    public let xRotOutput: Socket
    public let yRotOutput: Socket
    public let zRotOutput: Socket
    
    // MARK: - GyroscopeNode
    
    public struct Constants {
        public static let defaultSampleRate: Double = 60.0
    }
    
    public init(samplingFrequenctInHertz frequency: Double = Constants.defaultSampleRate,
                xRotOutput: Socket = Socket(title: "rX", kind: .output),
                yRotOutput: Socket = Socket(title: "rY", kind: .output),
                zRotOutput: Socket = Socket(title: "rZ", kind: .output),
                pitchOutput: Socket = Socket(title: "Pitch", kind: .output),
                rollOutput: Socket = Socket(title: "Roll", kind: .output),
                yawOutput: Socket = Socket(title: "Yaw", kind: .output)) {
        
        self.pitchOutput = pitchOutput
        self.rollOutput = rollOutput
        self.yawOutput = yawOutput
        
        self.xRotOutput = xRotOutput
        self.yRotOutput = yRotOutput
        self.zRotOutput = zRotOutput
        
        self.frequencyInput = Socket(title: "Hz", kind: .input, value: .double(frequency))
        
        super.init(title: "Gyroscope",
                   inputs: [ self.frequencyInput ],
                   outputs: [ self.xRotOutput, self.yRotOutput, self.zRotOutput, self.pitchOutput, self.rollOutput, self.yawOutput ])
        
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
        if let data = self.motion.deviceMotion?.attitude {
            self.pitchOutput.value = .double(data.pitch)
            self.rollOutput.value = .double(data.roll)
            self.yawOutput.value = .double(data.yaw)
        }
        
        if let data = self.motion.deviceMotion?.rotationRate {
            self.xRotOutput.value = .double(data.x)
            self.yRotOutput.value = .double(data.y)
            self.zRotOutput.value = .double(data.z)
        }
    }
}
