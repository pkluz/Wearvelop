//
//  CollectionKeyPathNode.swift
//  Wearvelop
//
//  Created by Philip Kluz on 2019-01-10.
//  Copyright © 2019 Philip Kluz. All rights reserved.
//

import UIKit

/// Node that permits access to a keyPath coded collection.
/// => Permits access to singular or nested keys within a `map` data structure.
///
/// KeyPaths are delimited by `.`, e.g. `keyA.keyB.keyC` would attempt to unwrap myMap["keyA"]["keyB"]["keyC"].
public class CollectionKeyPathNode: Node {
    
    // MARK: - CollectionKeyPathNode (Input)
    
    private let dataInput: Socket
    private let keyPathInput: Socket
    
    // MARK: - CollectionKeyPathNode (Output)
    
    private let output: Socket
    
    // MARK: - CollectionKeyPathNode
    
    public init() {
        self.dataInput = Socket(title: "Data", kind: .input)
        self.keyPathInput = Socket(title: "KeyPath", kind: .input)
        
        self.output = Socket(title: "Output", kind: .output)
        
        super.init(title: "Collection - KeyPath", inputs: [ self.dataInput, self.keyPathInput ], outputs: [ self.output ])
        
        self.dataInput.socketValueChanged = dataInputValueChanged
        self.keyPathInput.socketValueChanged = keyPathInputValueChanged
    }
    
    private func dataInputValueChanged(from maybeOldValue: Value?, to maybeNewValue: Value?) {
        guard let newData = maybeNewValue, let keyPath = keyPathInput.value else { return }
        generateNewOutput(data: newData, keyPath: keyPath)
    }
    
    private func keyPathInputValueChanged(from maybeOldValue: Value?, to maybeNewValue: Value?) {
        guard let newData = dataInput.value, let keyPath = maybeNewValue else { return }
        generateNewOutput(data: newData, keyPath: keyPath)
    }
    
    private func generateNewOutput(data: Value, keyPath: Value) {
        guard let keyPath = keyPath.unwrapAsString() else {
            output.value = nil
            return
        }
        
        if keyPath.contains(".") {
            let components = keyPath.components(separatedBy: ".")
            if let value = data.value(for: components) {
                output.value = value
            }
        } else if let value = data.value(for: [ keyPath ]) {
            output.value = value
        } else {
            output.value = nil
        }
    }
}
