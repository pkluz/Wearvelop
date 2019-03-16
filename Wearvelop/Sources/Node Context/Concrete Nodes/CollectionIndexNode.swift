//
//  CollectionIndexNode.swift
//  Wearvelop
//
//  Created by Philip Kluz on 2019-01-10.
//  Copyright © 2019 Philip Kluz. All rights reserved.
//

import UIKit

/// Node that permits access to an index coded collection.
///
/// `2` would attempt to unwrap myArray[2].
public class CollectionIndexNode: Node {
    
    // MARK: - CollectionIndexNode (Input)
    
    private let dataInput: Socket
    private let indexInput: Socket
    
    // MARK: - CollectionIndexNode (Output)
    
    private let output: Socket
    
    // MARK: - CollectionIndexNode
    
    public init() {
        self.dataInput = Socket(title: "Data", kind: .input)
        self.indexInput = Socket(title: "Index", kind: .input)
        
        self.output = Socket(title: "Output", kind: .output)
        
        super.init(title: "Collection - Index", inputs: [ self.dataInput, self.indexInput ], outputs: [ self.output ])
        
        self.dataInput.socketValueChanged = dataInputValueChanged
        self.indexInput.socketValueChanged = indexInputValueChanged
    }
    
    private func dataInputValueChanged(from maybeOldValue: Value?, to maybeNewValue: Value?) {
        guard let newData = maybeNewValue, let index = indexInput.value?.unwrapAsInt() else { return }
        generateNewOutput(data: newData, index: index)
    }
    
    private func indexInputValueChanged(from maybeOldValue: Value?, to maybeNewValue: Value?) {
        guard let newData = dataInput.value, let index = maybeNewValue?.unwrapAsInt() else { return }
        generateNewOutput(data: newData, index: index)
    }
    
    private func generateNewOutput(data: Value, index: Int) {
        if let value = data.value(at: index) {
            output.value = value
        } else {
            output.value = nil
        }
    }
}
