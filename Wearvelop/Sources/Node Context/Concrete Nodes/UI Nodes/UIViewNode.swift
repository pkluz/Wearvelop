//
//  UIViewNode.swift
//  Wearvelop
//
//  Created by Philip Kluz on 2019-03-13.
//  Copyright © 2019 Philip Kluz. All rights reserved.
//

import UIKit

public class UIViewNode: RenderContextNode {
    
    // MARK: - UIViewNode (Input)
    
    public let xInput: Socket
    public let yInput: Socket
    
    // MARK: - UIViewNode (Output)
    
    public let viewOutput: Socket
    
    // MARK: - ViewNode
    
    public init(x: Double,
                y: Double,
                width: Double,
                height: Double,
                title: String?,
                backgroundColor: Color = .white,
                extraInputs: [Socket],
                extraOutputs: [Socket]) {
        self.xInput = Socket(title: "X", kind: .input, value: .double(x))
        self.yInput = Socket(title: "Y", kind: .input, value: .double(y))
        
        self.viewOutput = Socket(title: "View", kind: .output)
        
        super.init(width: width, height: height, title: title ?? "UIView", inputs: [ self.xInput, self.yInput ] + extraInputs, outputs: [ self.viewOutput ] + extraOutputs)
        
        xInput.socketValueChanged = xInputValueChanged
        yInput.socketValueChanged = yInputValueChanged
    }
    
    public var frame: CGRect {
        return CGRect(x: xInput.value?.unwrapAsCGFloat() ?? 0.0,
                      y: yInput.value?.unwrapAsCGFloat() ?? 0.0,
                      width: widthInput.value?.unwrapAsCGFloat() ?? 0.0,
                      height: heightInput.value?.unwrapAsCGFloat() ?? 0.0)
    }
    
    public var backgroundColor: Color {
        return backgroundColorInput.value?.unwrapAsColor() ?? Color.white
    }
    
    public var subviews: [UIViewValue] {
        if let subviews = viewsInput.value?.unwrapAsViewValueArray(), !subviews.isEmpty {
            return subviews
        } else if let view = viewsInput.value?.unwrapAsViewValue() {
            return [ view ]
        }
        
        return []
    }
    
    public var viewValue: UIViewValue {
        return _viewValue
    }
    
    private lazy var _viewValue: UIViewValue =  {
        return UIViewValue(frame: frame, backgroundColor: backgroundColor, subviews: subviews)
    }()
    
    public func refreshViewValue() {
        viewValue.frame = frame
        viewValue.backgroundColor = backgroundColor
        viewValue.subviews = subviews
    }
    
    public func refreshOutput() {
        refreshViewValue()
        viewOutput.value = viewValue.toValue()
    }
    
    public func xInputValueChanged(from maybeOldValue: Value?, to maybeNewValue: Value?) {
        delegate?.nodeChanged(self)
        refreshOutput()
    }
    
    public func yInputValueChanged(from maybeOldValue: Value?, to maybeNewValue: Value?) {
        delegate?.nodeChanged(self)
        refreshOutput()
    }
    
    // MARK: - RenderContextNode
    
    public override func widthInputValueChanged(from maybeOldValue: Value?, to maybeNewValue: Value?) {
        super.widthInputValueChanged(from: maybeOldValue, to: maybeNewValue)
        refreshOutput()
    }
    
    public override func heightInputValueChanged(from maybeOldValue: Value?, to maybeNewValue: Value?) {
        super.heightInputValueChanged(from: maybeOldValue, to: maybeNewValue)
        refreshOutput()
    }
    
    public override func backgroundColorInputValueChanged(from maybeOldValue: Value?, to maybeNewValue: Value?) {
        super.backgroundColorInputValueChanged(from: maybeOldValue, to: maybeNewValue)
        refreshOutput()
    }
    
    public override func viewsInputValueChanged(from maybeOldValue: Value?, to maybeNewValue: Value?) {
        refreshViewValue()
        super.viewsInputValueChanged(from: maybeOldValue, to: maybeNewValue)
        refreshOutput()
    }
}
