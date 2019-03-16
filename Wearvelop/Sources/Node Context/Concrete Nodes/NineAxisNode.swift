//
//  9AxisNode.swift
//  Wearvelop
//
//  Created by Philip Kluz on 2019-02-24.
//  Copyright © 2019 Philip Kluz. All rights reserved.
//

import UIKit
import CoreMotion

/// **Composite Node** made up of three individual sensor nodes. Provides access to continously delivered 9-Axis X, Y, and Z values originating fro the device's internal accelerometer.
public class NineAxisNode: Node {

    // MARK: - NineAxisNode (Input)
    
    public let frequencyInput: Socket
    
    // MARK: - NineAxisNode (Output)
    
    private let accelerometerNode: AccelerometerNode
    private let gyroscopeNode: GyroscopeNode
    private let magnetometerNode: MagnetometerNode
    
    public let xAccelOutput: Socket
    public let yAccelOutput: Socket
    public let zAccelOutput: Socket
    
    public let pitchGyroOutput: Socket
    public let rollGyroOutput: Socket
    public let yawGyroOutput: Socket
    
    public let xMagOutput: Socket
    public let yMagOutput: Socket
    public let zMagOutput: Socket
    
    // MARK: - NineAxisNode
    
    public struct Constants {
        public static let defaultSampleRate: Double = 60.0
    }
    
    public init(samplingFrequenctInHertz frequency: Double = Constants.defaultSampleRate) {
        self.xAccelOutput = Socket(title: "aX", kind: .output)
        self.yAccelOutput = Socket(title: "aY", kind: .output)
        self.zAccelOutput = Socket(title: "aZ", kind: .output)
        
        self.pitchGyroOutput = Socket(title: "Pitch", kind: .output)
        self.rollGyroOutput = Socket(title: "Roll", kind: .output)
        self.yawGyroOutput = Socket(title: "Yaw", kind: .output)
        
        self.xMagOutput = Socket(title: "mX", kind: .output)
        self.yMagOutput = Socket(title: "mY", kind: .output)
        self.zMagOutput = Socket(title: "mZ", kind: .output)
        
        self.accelerometerNode = AccelerometerNode(samplingFrequenctInHertz: frequency,
                                                   xSocket: xAccelOutput,
                                                   ySocket: yAccelOutput,
                                                   zSocket: zAccelOutput)
        
        self.gyroscopeNode = GyroscopeNode(samplingFrequenctInHertz: frequency,
                                           pitchOutput: pitchGyroOutput,
                                           rollOutput: rollGyroOutput,
                                           yawOutput: yawGyroOutput)
        
        self.magnetometerNode = MagnetometerNode(samplingFrequenctInHertz: frequency,
                                                 xSocket: xMagOutput,
                                                 ySocket: yMagOutput,
                                                 zSocket: zMagOutput)
        
        self.frequencyInput = Socket(title: "Hz", kind: .input, value: .double(frequency))
        
        super.init(title: "9-Axis",
                   inputs: [ self.frequencyInput ],
                   outputs: [ self.xAccelOutput, self.yAccelOutput, self.zAccelOutput,
                              self.pitchGyroOutput, self.rollGyroOutput, self.yawGyroOutput,
                              self.xMagOutput, self.yMagOutput, self.zMagOutput ])
        
        self.frequencyInput.socketValueChanged = samplingRateChanged
    }
    
    private func samplingRateChanged(from maybeOldValue: Value?, to maybeNewValue: Value?) {
        self.accelerometerNode.frequencyInput.value = maybeNewValue
        self.gyroscopeNode.frequencyInput.value = maybeNewValue
        self.magnetometerNode.frequencyInput.value = maybeNewValue
    }
}
