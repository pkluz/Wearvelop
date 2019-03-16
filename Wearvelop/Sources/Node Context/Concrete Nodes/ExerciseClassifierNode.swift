//
//  ExerciseClassifierNode.swift
//  Wearvelop
//
//  Created by Philip Kluz on 2019-01-28.
//  Copyright © 2019 Philip Kluz. All rights reserved.
//

import UIKit
import CoreML
import AVFoundation

/// The exercise classifier node operates on a continuous stream of accelerometer input data
/// and classifies the input as either break, burpee, situp, or squat.
///
/// The underlying model used was first trained by Stephan Lerner ( https://github.com/Lausbert )
/// and released as part of his `Exermote` project.
///
/// His trained model is preferred, as it achieves a much higher accuracy than mine.
/// Regardless, it is recommended to improve this model further.
///
/// Source (MIT): https://github.com/Lausbert/Exermote/blob/master/ExermoteInference/ExermoteCoreML/ExermoteCoreML/Model/Exermote.mlmodel
///
public class ExerciseClassifierNode: Node {
    
    // MARK: - ExerciseClassifierNode (Input)
    
    /* Input is expected to be an array with exactly 40 entries of arrays in the form of:
     
    [
      ...
      [
        xGravity,
        yGravity,
        zGravity,
        xAcceleration,
        yAcceleration,
        zAcceleration,
        pitch,
        roll,
        yaw,
        xRotationRate,
        yRotationRate,
        zRotationRate
      ],
      ...
    ].count == 40
     
    */
    
    public let input: Socket
    
    // MARK: - ExerciseClassifierNode (Output)
    
    public let output: Socket
    
    // MARK: - ExerciseClassifierNode
    
    private lazy var classifier = ExerciseClassifier(delegate: self)
    private let speechSynthesizer = AVSpeechSynthesizer()
    
    public init() {
        self.input = Socket(title: "Input", kind: .input)
        self.output = Socket(title: "Output", kind: .output)

        super.init(title: "Exercise Classifier", inputs: [ self.input ], outputs: [ self.output ])
        
        self.input.socketValueChanged = inputValueChanged
    }
    
    private func inputValueChanged(from maybeOldValue: Value?, to maybeNewValue: Value?) {
        guard let value = maybeNewValue else { return }
        predict(input: value)
    }
    
    private func predict(input value: Value) {
        guard let rootArray = value.unwrapAsArray() else { return }
        let bufferedMotionData = rootArray.map({ $0.unwrapAsArray()?.compactMap({ $0.unwrapAsDouble() }) }).compactMap({ $0 })
        
        let datapoints = bufferedMotionData.flatMap({ $0 })
        guard datapoints.count == 480 else { return }
        
        classifier.predict(with: bufferedMotionData)
    }
}

extension ExerciseClassifierNode: ExerciseClassifierDelegate {
    
    public func didDetectRepetition(exercise: ExerciseClassifier.Exercise) {
        output.value = .string(exercise.rawValue)
        
        let utterance = AVSpeechUtterance(string: exercise.rawValue)
        utterance.rate = 0.4
        speechSynthesizer.speak(utterance)
    }
    
    public func didDetectSetBreak() {
        output.value = .string(ExerciseClassifier.Exercise.break.rawValue)
        
        let utterance = AVSpeechUtterance(string: ExerciseClassifier.Exercise.break.rawValue)
        utterance.rate = 0.4
        speechSynthesizer.speak(utterance)
    }
    
    public func didChangeState(state: ExerciseClassifier.State) {
        // NOOP
    }
}

public protocol ExerciseClassifierDelegate: AnyObject {
    func didDetectRepetition(exercise: ExerciseClassifier.Exercise)
    func didDetectSetBreak()
    func didChangeState(state: ExerciseClassifier.State)
}

public final class ExerciseClassifier {
    
    // Predetermined Constants
    static let kScalingCoefficients: [[Double]] = [ [0.5, 0.5, 0.5, 0.07007708, 0.07621951, 0.06131208, 0.31948882,  0.15923567, 0.15923567, 0.04504505, 0.03229974, 0.05347594],
                                                    [0.5, 0.5, 0.5, 0.49544499, 0.5007622, 0.527897, 0.49840256, 0.5, 0.5, 0.54414414, 0.55620155, 0.53475936] ]
    
    public final class Step {
        var exercise: Exercise?
        var next: Step?
    }

    public enum State: String {
        case notEvaluating = "Not Evaluating"
        case evaluating = "Evaluating"
        case initializing = "Initializing"
    }
    
    public enum Exercise: String {
        case burpee = "Burpee"
        case situp = "Situp"
        case squat = "Squat"
        case `break` = "Break"
    }
    
    private let model = Exermote()
    public private(set) var isEvaluating: Bool = false
    
    private var currentEvaluationStep: Step?
    private var lastEvaluationStep: Step?
    private var currentScaledMotionArrays: [[Double]] = []
    private var currentExercise: Exercise?
    private var evalutationStepsSinceLastRepetition: Int?
    private var state: State = .notEvaluating
    public weak var delegate: ExerciseClassifierDelegate?
    
    public init(delegate: ExerciseClassifierDelegate) {
        self.delegate = delegate
        changeState(to: state)
    }
    
    public func predict(with input: [[Double]]) {
        currentScaledMotionArrays = input.map { scaleRawMotionArray(rawMotionArray: $0) }
        
        changeState(to: .evaluating)
        
        let step = Step()
        if currentEvaluationStep == nil {
            currentEvaluationStep = step
            lastEvaluationStep = step
        } else {
            lastEvaluationStep?.next = step
            lastEvaluationStep = step
        }
        
        DispatchQueue.global(qos: .utility).async {
            self.makePredictionRequest(with: step)
        }
    }
    
    private func scaleRawMotionArray(rawMotionArray: [Double]) -> [Double] {
        let scaledMotionArray = rawMotionArray.enumerated().map { $0.element * ExerciseClassifier.kScalingCoefficients[0][$0.offset] + ExerciseClassifier.kScalingCoefficients[1][$0.offset] }
        return scaledMotionArray
    }
    
    private func makePredictionRequest(with step: Step) {
        let data = currentScaledMotionArrays.reduce([], +)
        
        do {
            let accelerationsMultiArray = try MLMultiArray(shape:[40, 1, 12], dataType: .double)
            for (index, element) in data.enumerated() {
                accelerationsMultiArray[index] = NSNumber(value: element)
            }
            
            let hiddenStatesMultiArray = try MLMultiArray(shape: [32], dataType: .double)
            for index in 0..<32 {
                hiddenStatesMultiArray[index] = NSNumber(integerLiteral: 0)
            }
            
            let input = ExermoteInput(accelerations: accelerationsMultiArray,
                                      lstm_1_h_in: hiddenStatesMultiArray,
                                      lstm_1_c_in: hiddenStatesMultiArray,
                                      lstm_2_h_in: hiddenStatesMultiArray,
                                      lstm_2_c_in: hiddenStatesMultiArray)
            
            let predictionOutput = try model.prediction(input: input)
            if let scores = [ predictionOutput.scores[0],
                              predictionOutput.scores[1],
                              predictionOutput.scores[2],
                              predictionOutput.scores[3] ] as? [Double] {
                let exercise = decodePredictionRequest(scores: scores)
                
                DispatchQueue.main.async {
                    self.delegate?.didDetectRepetition(exercise: exercise)
                }
            } else {
                // NOOP
            }
        }
        catch (let error) {
            print("Error: \(error.localizedDescription)")
            
            changeState(to: .notEvaluating)
        }
    }
    
    private func decodePredictionRequest(scores: [Double]) -> Exercise {
        if let maximumScore = scores.max() {
            if let maximumScoreIndex = scores.index(of: maximumScore) {
                let exercises: [Exercise] =  [.break, .burpee, .situp, .squat]
                return exercises[maximumScoreIndex]
            }
        }
        
        return .break
    }
    
    private func tryEvaluation() {
        isEvaluating = true
        defer { isEvaluating = false }
        
        while currentEvaluationStep?.next != nil {
            guard let currentExercise = currentEvaluationStep?.exercise else { return }
            
            if self.currentExercise == currentExercise {
                if currentExercise == .break {
                    if var steps = evalutationStepsSinceLastRepetition {
                        steps += 1
                        
                        evalutationStepsSinceLastRepetition = steps
                        DispatchQueue.main.async {
                            self.delegate?.didDetectSetBreak()
                        }
                    }
                }
            } else {
                switch currentExercise {
                case .break:
                    guard let consecutiveBreakPrediction = exercisePredictedForConsecutiveSteps(step: currentEvaluationStep, steps: 2) else {return}
                    if consecutiveBreakPrediction {
                        evalutationStepsSinceLastRepetition = 0
                        
                        DispatchQueue.main.async {
                            self.delegate?.didDetectSetBreak()
                        }
                    }
                case .burpee:
                    guard let consecutiveExercisePrediction = exercisePredictedForConsecutiveSteps(step: currentEvaluationStep, steps: 15) else {return}
                    if consecutiveExercisePrediction {
                        DispatchQueue.main.async {
                            self.delegate?.didDetectRepetition(exercise: currentExercise)
                        }
                    }
                case .squat:
                    guard let consecutiveExercisePrediction = exercisePredictedForConsecutiveSteps(step: currentEvaluationStep, steps: 5) else {return}
                    if consecutiveExercisePrediction {
                        DispatchQueue.main.async {
                            self.delegate?.didDetectRepetition(exercise: currentExercise)
                        }
                    }
                case .situp:
                    guard let consecutiveExercisePrediction = exercisePredictedForConsecutiveSteps(step: currentEvaluationStep, steps: 10) else {return}
                    if consecutiveExercisePrediction {
                        DispatchQueue.main.async {
                            self.delegate?.didDetectRepetition(exercise: currentExercise)
                        }
                    }
                }
            }
            
            self.currentExercise = currentExercise
            currentEvaluationStep = currentEvaluationStep?.next
        }
    }
    
    private func exercisePredictedForConsecutiveSteps(step: Step?, steps: Int) -> Bool? {
        if steps <= 0 {
            return true
        }
        
        guard let exercise = step?.exercise, let nextExercise = step?.next?.exercise else { return nil }
        
        if exercise != nextExercise {
            return false
        }
        
        return exercisePredictedForConsecutiveSteps(step: step?.next ,steps: steps - 1)
    }
    
    private func changeState(to newState: State) {
        state = newState
        delegate?.didChangeState(state: newState)
    }
}
