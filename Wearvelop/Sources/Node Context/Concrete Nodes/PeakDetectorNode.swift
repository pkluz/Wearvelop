//
//  PeakDetectorNode.swift
//  Wearvelop
//
//  Created by Philip Kluz on 2019-02-28.
//  Copyright © 2019 Philip Kluz. All rights reserved.
//

import UIKit

/// A peak detector node, which operates on an array of values
public class PeakDetectorNode: Node {
    
    // MARK: - PeakDetectorNode (Input)
    
    private let dataInput: Socket
    private let minCountInput: Socket
    private let thresholdInput: Socket
    private let influenceInput: Socket
    
    // MARK: - PeakDetectorNode (Output)
    
    private let passthroughOutput: Socket
    private let peaksOutput: Socket
    private let averageOutput: Socket
    private let standardsOutput: Socket
    
    // MARK: - PeakDetectorNode
    
    public init() {
        self.dataInput = Socket(title: "Values", kind: .input)
        self.minCountInput = Socket(title: "Min Count", kind: .input)
        self.thresholdInput = Socket(title: "Threshold", kind: .input)
        self.influenceInput = Socket(title: "Influence", kind: .input)
        
        self.passthroughOutput = Socket(title: "Passthrough", kind: .output)
        self.peaksOutput = Socket(title: "Peaks", kind: .output)
        self.averageOutput = Socket(title: "Averages", kind: .output)
        self.standardsOutput = Socket(title: "Standard", kind: .output)
        
        super.init(title: "Peak Detector",
                   inputs: [ self.dataInput, self.minCountInput, self.thresholdInput, self.influenceInput ],
                   outputs: [ self.passthroughOutput, self.peaksOutput, self.averageOutput, self.standardsOutput ])
        
        self.dataInput.socketValueChanged = dataInputValueChanged
        self.minCountInput.socketValueChanged = minCountInputValueChanged
        self.thresholdInput.socketValueChanged = thresholdInputValueChanged
        self.influenceInput.socketValueChanged = influenceInputValueChanged
    }
    
    private func computePeaksIfPossible() {
        guard let rawInput = dataInput.value,
            let data = rawInput.unwrapAsArray()?.map({ $0.unwrapAsDouble() }).compactMap({ $0 }),
            let minCount = minCountInput.value?.unwrapAsInt(),
            let threshold = thresholdInput.value?.unwrapAsDouble(),
            let influence = influenceInput.value?.unwrapAsDouble() else { return }
        
        let (peaks, averages, standards) = PeakDetector.apply(input: data, minCount: minCount, threshold: threshold, influence: influence)
        
        passthroughOutput.value = rawInput
        peaksOutput.value = peaks.toValue()
        averageOutput.value = averages.toValue()
        standardsOutput.value = standards.toValue()
    }
    
    private func dataInputValueChanged(from maybeOldValue: Value?, to maybeNewValue: Value?) {
        computePeaksIfPossible()
    }
    
    private func minCountInputValueChanged(from maybeOldValue: Value?, to maybeNewValue: Value?) {
        computePeaksIfPossible()
    }
    
    private func thresholdInputValueChanged(from maybeOldValue: Value?, to maybeNewValue: Value?) {
        computePeaksIfPossible()
    }
    
    private func influenceInputValueChanged(from maybeOldValue: Value?, to maybeNewValue: Value?) {
        computePeaksIfPossible()
    }
}

/// Based on ideas developed by `Jean-Paul van Brakel`.
/// Published at https://stackoverflow.com/questions/22583391/peak-signal-detection-in-realtime-timeseries-data/22640362#22640362
/// Adapted by Philip Kluz
///
/// Basic Z-Scoring algorithm. Not the most efficient approach due to some unnecessary looping.
public enum PeakDetector {

    public typealias DetectorResult = (peaks: [Int], averages: [Double], standards: [Double])
    
    public static func apply(input: [Double], minCount: Int, threshold: Double, influence: Double) -> DetectorResult {
        var peaks = Array(repeating: 0, count: input.count)
        var filteredInput = Array(repeating: 0.0, count: input.count)
        var averageFilter = Array(repeating: 0.0, count: input.count)
        var standardDevFilter = Array(repeating: 0.0, count: input.count)
        
        for i in 0...minCount-1 {
            peaks[i] = 0
            filteredInput[i] = input[i]
        }
        
        let upper = min(minCount - 1, input.count)
        
        averageFilter[minCount - 1] = Array(input[0..<upper]).average()
        standardDevFilter[minCount - 1] = Array(input[0..<upper]).standardDeviation()
        
        for i in minCount...input.count-1 {
            if abs(input[i] - averageFilter[i - 1]) > standardDevFilter[i - 1] * threshold {
                if input[i] > averageFilter[i - 1] {
                    peaks[i] = 1
                } else {
                    peaks[i] = -1
                }
                filteredInput[i] = influence * input[i] + (1 - influence) * filteredInput[i - 1]
            } else {
                peaks[i] = 0
                filteredInput[i] = input[i]
            }
            
            let lower = i - minCount
            let upper = min(filteredInput.count, i)
            
            averageFilter[i] = Array(filteredInput[lower..<upper]).average()
            standardDevFilter[i] = Array(filteredInput[lower..<upper]).average()
        }
        
        return DetectorResult(peaks: peaks, averages: averageFilter, standards: standardDevFilter)
    }
}

