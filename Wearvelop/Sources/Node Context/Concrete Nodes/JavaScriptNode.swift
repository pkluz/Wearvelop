//
//  JavaScriptNode.swift
//  Wearvelop
//
//  Created by Philip Kluz on 2019-02-23.
//  Copyright © 2019 Philip Kluz. All rights reserved.
//

import UIKit
import JavaScriptCore

public class JavaScriptNode: Node {
    
    // MARK: - JavaScriptNode (Input)
    
    private let argumentInputs: [Socket]
    private let scriptInput: Socket
    
    // MARK: - JavaScriptNode (Output)
    
    private let output: Socket
    
    // MARK: - JavaScriptNode
    
    private var script: String? = nil
    
    private var arguments: [Value]? {
        var result: [Value] = []
        for argument in argumentInputs {
            if let value = argument.value {
                result.append(value)
            }
        }
        
        if result.count == arity {
            return result
        }
        
        return nil
    }
    
    private let arity: Int
    
    public init(with arity: Int) {
        self.argumentInputs = Array(0..<arity).map { index -> Socket in
            return Socket(title: "Arg #\(index)", kind: .input)
        }
        
        self.arity = arity
        self.scriptInput = Socket(title: "Script", kind: .input)
        
        self.output = Socket(title: "Output", kind: .output)
        
        super.init(title: "JavaScript", inputs: self.argumentInputs + [ self.scriptInput ], outputs: [ self.output ])

        for socket in self.argumentInputs {
            socket.socketValueChanged = argumentInputValueChanged
        }

        self.scriptInput.socketValueChanged = scriptInputValueChanged
    }
    
    private func argumentInputValueChanged(from maybeOldValue: Value?, to maybeNewValue: Value?) {
        computeResultIfNecessary()
    }
    
    private func scriptInputValueChanged(from maybeOldValue: Value?, to maybeNewValue: Value?) {
        if let value = maybeNewValue?.unwrapAsString() {
            script = value
        } else {
            script = nil
        }

        computeResultIfNecessary()
    }
    
    private func computeResultIfNecessary() {
        guard let script = script,
              let arguments = self.arguments?.map({ $0.toDictionary() }).compactMap({ $0 }),
              arguments.count == arity
        else { return }

        let context = JSContext()
        context?.evaluateScript(script)
        let applyFunction = context?.objectForKeyedSubscript("apply")
        if let result = applyFunction?.call(withArguments: arguments) {
            if result.isArray {
                let array = result.toArray() as NSArray
                let value = array.toValue()
                output.value = value
            } else if result.isObject {
                let object = result.toDictionary() as NSDictionary
                let value = object.toValue()
                output.value = value
            } else if result.isNumber {
                let object = result.toNumber()
                let value = object?.toValue()
                output.value = value
            } else if result.isBoolean {
                let value = result.toBool()
                output.value = value.toValue()
            } else if result.isString {
                let value = result.toString()
                output.value = value?.toValue()
            } else if result.isUndefined {
                output.value = .string(".undefined")
            } else if result.isNull {
                output.value = .string(".null")
            } else if result.isDate {
                if let value = result.toDate() {
                    let string = defaultDateFormatter.string(from: value)
                    output.value = .string(string)
                }
            }
        }
    }
}
