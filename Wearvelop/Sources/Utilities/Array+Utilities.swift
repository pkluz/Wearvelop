//
//  Array+Index.swift
//  Annotator
//
//  Created by Philip Kluz on 2019-01-04.
//  Copyright © 2019 Philip Kluz. All rights reserved.
//

import Foundation

// Source (MIT): http://stackoverflow.com/a/30593673

public extension Collection {
    
    /// Returns the element at the specified index iff it is within bounds, otherwise nil.
    public subscript (safe index: Index) -> Iterator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

extension Array where Element == Double {
    
    public func average() -> Double {
        var total: Double = 0.0
        for number in self {
            total += number
        }
        return total / Double(self.count)
    }
    
    public func standardDeviation() -> Double {
        let size = Double(count)
        let average = self.average()
        let result = map { pow($0 - average, 2.0)}.reduce(0, +)
        return sqrt(result / size)
    }
}
