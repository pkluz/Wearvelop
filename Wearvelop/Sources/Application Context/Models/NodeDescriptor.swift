//
//  NodeDescriptor.swift
//  Wearvelop
//
//  Created by Philip Kluz on 2018-12-02.
//  Copyright © 2018 Philip Kluz. All rights reserved.
//

import UIKit

public enum NodeDescriptor: CaseIterable {
    case constant
    case scalar
    case socketListener
    case socketWriter
    case exerciseClassifier
    case chart
    case collectionIndex
    case collectionKeyPath
    case combineLatest
    case buffer
    case throttle
    case debounce
    case minimum
    case maximum
    case merge
    case javaScript
    case nineAxis
    case accelerometer
    case gyroscope
    case magnetometer
    case lowPassFilter
    case highPassFilter
    case peakDetector
    case segmentation
    case ringBuffer
    case timer
    case zip
    case print
    case renderContext
    case view
    case switchView
    
    public var title: String {
        switch self {
        case .constant:
            return "Constant"
        case .buffer:
            return "Buffer"
        case .combineLatest:
            return "Combine Latest"
        case .exerciseClassifier:
            return "Exercise Classifier"
        case .chart:
            return "Chart"
        case .collectionIndex:
            return "Collection (Index)"
        case .collectionKeyPath:
            return "Collection (KeyPath)"
        case .socketWriter:
            return "Socket (Writer)"
        case .socketListener:
            return "Socket (Listener)"
        case .javaScript:
            return "JavaScript"
        case .throttle:
            return "Throttle"
        case .debounce:
            return "Debounce"
        case .peakDetector:
            return "Peak Detector"
        case .segmentation:
            return "Segmentation"
        case .minimum:
            return "Minimum"
        case .maximum:
            return "Maximum"
        case .merge:
            return "Merge"
        case .scalar:
            return "Scalar"
        case .nineAxis:
            return "Nine-Axis"
        case .accelerometer:
            return "Accelerometer"
        case .gyroscope:
            return "Gyroscope"
        case .magnetometer:
            return "Magnetometer"
        case .lowPassFilter:
            return "Low-Pass Filter"
        case .highPassFilter:
            return "High-Pass Filter"
        case .ringBuffer:
            return "Ring Buffer"
        case .timer:
            return "Timer"
        case .print:
            return "Print"
        case .zip:
            return "Zip"
        case .renderContext:
            return "Render Context"
        case .view:
            return "UIView"
        case .switchView:
            return "UISwitch"
        }
    }
    
    public var subtitle: String {
        switch self {
        case .constant:
            return "Delivers a constant value. Supports decoding of JSON objects."
        case .combineLatest:
            return "Buffers a series of incoming values and delivers them as an array of a predefined arity."
        case .exerciseClassifier:
            return "The exercise classifier node operates on a continuous stream of accelerometer input data and classifies the input as either break, burpee, situp, or squat. The expected input is an array of 40 data sets, of which each contains 12 doubles (xGrav, yGrav, zGrav, xAcc, yAcc, zAcc, pitch, roll, yaw, xRot, yRot, zRot)."
        case .socketListener:
            return "Listens for incoming messages on the input port and relays them as values as they come in."
        case .socketWriter:
            return "Sends incoming messages to the input ip/port."
        case .javaScript:
            return "A programmable node taking a predefines number of arguments and a function to produce an output. Runs synchronously."
        case .collectionKeyPath:
            return "Attempts to access a given key path within a map value type or any other collection type supporting keyPath based access."
        case .collectionIndex:
            return "Attempts to access a given index within an array value type or any other collection type supporting index based access."
        case .buffer:
            return "Buffers incoming values up to a predefined buffer size and delivers the buffer as an array."
        case .chart:
            return "Displays a graph charting a series of discrete incoming values."
        case .throttle:
            return "Throttles incoming values and only relays the most recent value after some seconds have passed."
        case .peakDetector:
            return "Allows for the detection of sudden peaks in a series of data. Leverages a smoothed z-score algorithm (i.e. the number of standard deviations a point is away from the mean)."
        case .segmentation:
            return "A segmentation node, which operates on an array of raw input data as well as an array of equivalent arity with peak signals. Decomposes incoming data into segments centered around the peaks within the input data with range [p-n, p+n]"
        case .debounce:
            return "Debounces incoming values and only relays the most recent value if the input signal has not delivered a value in the previous number of seconds."
        case .minimum:
            return "Returns the minimum from an input array of values."
        case .maximum:
            return "Returns the maximum from an input array of values."
        case .merge:
            return "Node that combines a dynamic number of inputs into an single output stream by relaying all values as they come in on one channel."
        case .nineAxis:
            return "Delivers three pairs of X, Y, and Z values from the devices built-in accelerometer, gyroscope, and magnetometer."
        case .accelerometer:
            return "Delivers X, Y, Z acceleration and gX, gY, gZ gravitational values from the device's built-in accelerometer."
        case .gyroscope:
            return "Delivers X, Y, Z, rotation rate as well as pitch, roll, and yaw values from the device's built-in gyroscope."
        case .magnetometer:
            return "Delivers X, Y, and Z magnetic values from the device's built-in magnetometer."
        case .scalar:
            return "Multiplys a value by a scalar."
        case .lowPassFilter:
            return "Applies a simple low-pass filter to incoming values."
        case .highPassFilter:
            return "Applies a simple high-pass filter to incoming values."
        case .ringBuffer:
            return "Prints the incoming values on-screen."
        case .timer:
            return "Timer that fires a signal every x seconds."
        case .print:
            return "Prints the incoming values on-screen."
        case .zip:
            return "Combines all the most recent outputs of all inputs into a single array. A new value is only generated once each input delivers a value."
        case .renderContext:
            return "Creates a renderable context node. Allows for arbitrary drawing within the context."
        case .view:
            return "Creates a basic UIView node."
        case .switchView:
            return "Creates a basic UISwitch node."
        }
    }
    
    public var image: UIImage? {
        return UIImage(named: "icon-node-generic")
    }
    
    public func build(with value: Value?) -> DisplayNode? {
        switch self {
        case .constant:
            guard let value = value else { return nil }
            return ConstantDisplayNode(value: value)
        case .exerciseClassifier:
            return DisplayNode(node: ExerciseClassifierNode())
        case .buffer:
            return DisplayNode(node: BufferNode(size: 40))
        case .chart:
            return ChartDisplayNode(capacity: 205, inputs: 1)
        case .collectionKeyPath:
            return DisplayNode(node: CollectionKeyPathNode())
        case .collectionIndex:
            return DisplayNode(node: CollectionIndexNode())
        case .combineLatest:
            return DisplayNode(node: CombineLatestNode(inputs: 2))
        case .throttle:
            return DisplayNode(node: ThrottleNode())
        case .socketListener:
            return DisplayNode(node: SocketListenerNode())
        case .socketWriter:
            return DisplayNode(node: SocketWriterNode())
        case .debounce:
            return DisplayNode(node: DebounceNode())
        case .minimum:
            return DisplayNode(node: MinimumNode())
        case .maximum:
            return DisplayNode(node: MaximumNode())
        case .javaScript:
            return DisplayNode(node: JavaScriptNode(with: 1))
        case .merge:
            return DisplayNode(node: MergeNode(inputs: 2))
        case .nineAxis:
            return DisplayNode(node: NineAxisNode())
        case .peakDetector:
            return DisplayNode(node: PeakDetectorNode())
        case .segmentation:
            return DisplayNode(node: SegmentationNode())
        case .accelerometer:
            return DisplayNode(node: AccelerometerNode())
        case .gyroscope:
            return DisplayNode(node: GyroscopeNode())
        case .magnetometer:
            return DisplayNode(node: MagnetometerNode())
        case .scalar:
            return ScalarDisplayNode()
        case .lowPassFilter:
            return DisplayNode(node: LowPassFilterNode())
        case .highPassFilter:
            return DisplayNode(node: HighPassFilterNode())
        case .ringBuffer:
            return DisplayNode(node: RingBufferNode())
        case .timer:
            return DisplayNode(node: TimerNode(interval: 1.0))
        case .print:
            return PrintDisplayNode(value: value)
        case .zip:
            return DisplayNode(node: ZipNode(inputs: 2))
        case .renderContext:
            return RenderContextDisplayNode()
        case .view:
            return UIViewDisplayNode(x: 0.0, y: 0.0, width: 100.0, height: 50.0)
        case .switchView:
            return UISwitchDisplayNode(x: 0.0, y: 0.0, isOn: false)
        }
    }
}
