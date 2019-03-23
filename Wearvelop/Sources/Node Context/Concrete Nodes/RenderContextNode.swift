//
//  RenderContextNode.swift
//  Wearvelop
//
//  Created by Philip Kluz on 2019-03-05.
//  Copyright © 2019 Philip Kluz. All rights reserved.
//

import UIKit

// Node representing a render context.
public class RenderContextNode: Node {
    
    // MARK: - RenderContextNode (Input)
    
    public let widthInput: Socket
    public let heightInput: Socket
    public let backgroundColorInput: Socket
    public let viewsInput: Socket
    
    // MARK: - RenderContextNode
    
    public init(width: Double, height: Double, title: String = "Render Context", inputs: [Socket] = [], outputs: [Socket] = []) {
        self.widthInput = Socket(title: "Width", kind: .input, value: .double(width))
        self.heightInput = Socket(title: "Height", kind: .input, value: .double(height))
        self.backgroundColorInput = Socket(title: "Background", kind: .input)
        self.viewsInput = Socket(title: "Views", kind: .input, value: .array([]))
        
        super.init(title: title,
                   inputs: inputs + [ self.widthInput, self.heightInput, self.backgroundColorInput , self.viewsInput ],
                   outputs: outputs)
        
        widthInput.socketValueChanged = widthInputValueChanged
        heightInput.socketValueChanged = heightInputValueChanged
        viewsInput.socketValueChanged = viewsInputValueChanged
        backgroundColorInput.socketValueChanged = backgroundColorInputValueChanged
    }
    
    public func widthInputValueChanged(from maybeOldValue: Value?, to maybeNewValue: Value?) {
        delegate?.nodeChanged(self)
    }
    
    public func heightInputValueChanged(from maybeOldValue: Value?, to maybeNewValue: Value?) {
        delegate?.nodeChanged(self)
    }
    
    public func backgroundColorInputValueChanged(from maybeOldValue: Value?, to maybeNewValue: Value?) {
        delegate?.nodeChanged(self)
    }
    
    public func viewsInputValueChanged(from maybeOldValue: Value?, to maybeNewValue: Value?) {
        delegate?.nodeChanged(self)
    }
}
