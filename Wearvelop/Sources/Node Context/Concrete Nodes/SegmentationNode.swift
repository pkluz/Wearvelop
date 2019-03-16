//
//  SegmentationNode.swift
//  Wearvelop
//
//  Created by Philip Kluz on 2019-02-28.
//  Copyright © 2019 Philip Kluz. All rights reserved.
//

import UIKit

/// A segmentation node, which operates on an array of raw input data as well as an array of equivalent arity with peak signals. Decomposes incoming data into segments centered around the peaks within the input data with range [p-n, p+n]
public class SegmentationNode: Node {
    
    // MARK: - SegmentationNode (Input)
    
    private let dataInput: Socket
    private let peaksInput: Socket
    private let segmentRangeInput: Socket
    
    // MARK: - SegmentationNode (Output)
    
    private let passthroughOutput: Socket
    private let segmentsOutput: Socket
    
    // MARK: - SegmentationNode
    
    public enum Constants {
        public static let defaultN: Int = 5
    }
    
    public init() {
        self.dataInput = Socket(title: "Data", kind: .input)
        self.peaksInput = Socket(title: "Peaks", kind: .input)
        self.segmentRangeInput = Socket(title: "N", kind: .input)
        
        self.passthroughOutput = Socket(title: "Passthrough", kind: .output)
        self.segmentsOutput = Socket(title: "Segments", kind: .output)
        
        super.init(title: "Segmenter",
                   inputs: [ self.dataInput, self.peaksInput, self.segmentRangeInput ],
                   outputs: [ self.passthroughOutput, self.segmentsOutput ])
        
        self.dataInput.socketValueChanged = dataInputValueChanged
        self.segmentRangeInput.socketValueChanged = segmentRangeInputValueChanged
        self.peaksInput.socketValueChanged = peaksInputValueChanged
    }
    
    private func computeSegmentsIfPossible() {
        guard let rawInput = dataInput.value,
              let data = rawInput.unwrapAsArray()?.map({ $0.unwrapAsDouble() }).compactMap({ $0 }),
              let peaks = rawInput.unwrapAsArray()?.map({ $0.unwrapAsInt() }).compactMap({ $0 }),
              data.count == peaks.count else { return }
        
        let n = max(segmentRangeInput.value?.unwrapAsInt() ?? Constants.defaultN, 0)
        
        let segments = PeakSegmenter.apply(input: data, peaks: peaks, n: n)
        let valueSegments = segments.map { $0.toValue() }.toValue()
        
        passthroughOutput.value = rawInput
        segmentsOutput.value = valueSegments
    }
    
    private func dataInputValueChanged(from maybeOldValue: Value?, to maybeNewValue: Value?) {
        computeSegmentsIfPossible()
    }
    
    private func segmentRangeInputValueChanged(from maybeOldValue: Value?, to maybeNewValue: Value?) {
        computeSegmentsIfPossible()
    }
    
    private func peaksInputValueChanged(from maybeOldValue: Value?, to maybeNewValue: Value?) {
        computeSegmentsIfPossible()
    }
}

public enum PeakSegmenter {
    
    public static func apply(input: [Double], peaks: [Int], n: Int = 5) -> [[Double]] {
        var i = 0
        var peakRanges: [Range<Int>] = []
        
        var s = -1
        var e = -1
        
        while i < peaks.count {
            defer { i += 1 }
            
            if peaks[i] != 1 {
                if s != -1 && e != -1 {
                    peakRanges.append(Range(uncheckedBounds: (lower: max(0, s-n), upper: min(peaks.count, e + 1 + n))))
                }
                
                s = -1
                e = -1
                continue
            }
            
            if peaks[i] == 1 {
                if s == -1 { s = i }
                e = i
                
                if s != -1 && (i + 1 >= peaks.count) {
                    peakRanges.append(Range(uncheckedBounds: (lower: max(0, s-n), upper: peaks.count)))
                }
            }
        }
        
        return peakRanges.map { range -> [Double] in
            return Array(input[range])
        }
    }
}
