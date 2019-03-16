//
//  ProjectViewController.swift
//  Wearvelop
//
//  Created by Philip Kluz on 2018-11-12.
//  Copyright © 2018 Philip Kluz. All rights reserved.
//

import UIKit
import Parchment

public final class ProjectViewController: FixedPagingViewController, PagingViewControllerDelegate {
    
    public init(project: Project) {
        self.project = project
        self.canvasOne = CanvasViewController(title: "Canvas #1")
        self.canvasTwo = CanvasViewController(title: "Canvas #2")
        
        super.init(viewControllers: [
            canvasOne,
            canvasTwo
        ])
        
        self.delegate = self
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let canvasOne: CanvasViewController
    private let canvasTwo: CanvasViewController
    private let project: Project
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        indicatorColor = .darkGray
        selectedTextColor = .black
        textColor = .lightGray
        menuInteraction = .none
        contentInteraction = .none
        indicatorOptions = .visible(height: 2.0, zIndex: Int.max, spacing: .zero, insets: .zero)
        title = project.title
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        panelController.add(to: self, transition: .slide(direction: .vertical))
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        askForDemoSetupIfNecessary()
    }
    
    public override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        
        coordinator.animate(alongsideTransition: { _ in
            self.panelController.performWithoutAnimation {
                self.panelController.configuration = self.configuration(for: newCollection)
            }
        }, completion: nil)
    }
    
    public override var preferredScreenEdgesDeferringSystemGestures: UIRectEdge {
        return [ .bottom ]
    }
    
    // MARK: - ProjectViewController
    
    private lazy var panelController: Panel = makePanelController()

    private func makePanelController() -> Panel {
        let panelController = Panel(configuration: configuration(for: traitCollection))
        let nodeBrowserController = NodeBrowserViewController()
        nodeBrowserController.delegate = self
        let contentNavigationController = UINavigationController(rootViewController: nodeBrowserController)
        contentNavigationController.navigationBar.barTintColor = .white
        contentNavigationController.navigationBar.isTranslucent = false
        contentNavigationController.view.bringSubviewToFront(contentNavigationController.navigationBar)
        
        panelController.sizeDelegate = self
        panelController.resizeDelegate = self
        panelController.repositionDelegate = self
        panelController.contentViewController = contentNavigationController
        
        return panelController
    }
    
    private func configuration(for traitCollection: UITraitCollection) -> Panel.Configuration {
        var configuration = Panel.Configuration.default
        
        var panelPosition: Panel.Configuration.Position {
            if traitCollection.userInterfaceIdiom == .pad { return .trailingBottom }
            
            return traitCollection.verticalSizeClass == .compact ? .leadingBottom : .bottom
        }
        
        var panelMargins: NSDirectionalEdgeInsets {
            if traitCollection.userInterfaceIdiom == .pad  || traitCollection.hasNotch { return NSDirectionalEdgeInsets(top: 20.0, leading: 20.0, bottom: 20.0, trailing: 20.0) }
            
            let horizontalMargin: CGFloat = traitCollection.verticalSizeClass == .compact ? 20.0 : 0.0
            return NSDirectionalEdgeInsets(top: 20.0, leading: horizontalMargin, bottom: 0.0, trailing: horizontalMargin)
        }
        
        configuration.appearance.separatorColor = .white
        configuration.position = panelPosition
        configuration.margins = panelMargins
        
        if traitCollection.userInterfaceIdiom == .pad {
            configuration.supportedPositions = [.leadingBottom, .trailingBottom]
            configuration.appearance.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        } else {
            configuration.supportedModes = [.minimal, .compact, .expanded, .fullHeight]
            configuration.supportedPositions = [configuration.position]
            
            if traitCollection.hasNotch {
                configuration.appearance.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            } else {
                configuration.appearance.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            }
        }
        
        return configuration
    }
    
    public var currentCanvasViewController: CanvasViewController? {
        if canvasOne == self.pageViewController.selectedViewController {
            return canvasOne
        } else if canvasTwo == self.pageViewController.selectedViewController {
            return canvasTwo
        }
        
        return nil
    }
    
    @objc private func handleToggleVisibilityPress() {
        let transition = traitCollection.userInterfaceIdiom == .pad ? Panel.Transition.slide(direction: .horizontal) : Panel.Transition.slide(direction: .vertical)
        
        if panelController.isVisible {
            panelController.removeFromParent(transition: transition)
        } else {
            panelController.add(to: self, transition: transition)
        }
    }
    
    @objc private func handleToggleModePress() {
        let nextModeMapping: [Panel.Configuration.Mode: Panel.Configuration.Mode] = [ .compact: .expanded,
                                                                                      .expanded: .fullHeight,
                                                                                      .fullHeight: .compact ]
        guard let nextMode = nextModeMapping[panelController.configuration.mode] else { return }
        
        panelController.configuration.mode = nextMode
    }
    
    // MARK: - PanelViewController (Demo Setup)
    
    private var isFirstAppearance: Bool = true
    
    private func askForDemoSetupIfNecessary() {
        if isFirstAppearance {
            isFirstAppearance = false
            
            let alert = UIAlertController(title: "Setup Demo Application on Canvas #2?", message: "Would you like to see a demo project which classifies internal sensor motion?", preferredStyle: .alert)
            let showDemoAction = UIAlertAction(title: "Yes, Setup", style: .default) { [weak self] _ in
                self?.setupcanvasTwo()
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in }
            alert.addAction(showDemoAction)
            alert.addAction(cancelAction)
            present(alert, animated: true, completion: nil)
        }
    }
    
    private func setupcanvasTwo() {
        let context = canvasTwo.context
        
        let sampleRateNode = ConstantDisplayNode(value: .integer(10))
        let accelerometerNode = DisplayNode(node: AccelerometerNode())
        let gyroNode = DisplayNode(node: GyroscopeNode())
        let bufferNode = DisplayNode(node: BufferNode(size: 40))
        let zipNode = DisplayNode(node: ZipNode(inputs: 12))
        let classifierNode = DisplayNode(node: ExerciseClassifierNode())
        let printNode = PrintDisplayNode(value: nil)
        
        context.add(displayNode: sampleRateNode, shouldPositionRandomly: true)
        context.add(displayNode: accelerometerNode, shouldPositionRandomly: true)
        context.add(displayNode: gyroNode, shouldPositionRandomly: true)
        context.add(displayNode: bufferNode, shouldPositionRandomly: true)
        context.add(displayNode: zipNode, shouldPositionRandomly: true)
        context.add(displayNode: classifierNode, shouldPositionRandomly: true)
        context.add(displayNode: printNode, shouldPositionRandomly: true)
        
        if let source = sampleRateNode.node as? ConstantNode, let target = accelerometerNode.node as? AccelerometerNode {
            source.addLink(from: source.output, to: target, targetSocket: target.frequencyInput)
        }
        
        if let source = sampleRateNode.node as? ConstantNode, let target = gyroNode.node as? GyroscopeNode {
            source.addLink(from: source.output, to: target, targetSocket: target.frequencyInput)
        }
        
        if let source = accelerometerNode.node as? AccelerometerNode, let target = zipNode.node as? ZipNode {
            source.addLink(from: source.gxOutput, to: target, targetSocket: target.inputs[0])
            source.addLink(from: source.gyOutput, to: target, targetSocket: target.inputs[1])
            source.addLink(from: source.gzOutput, to: target, targetSocket: target.inputs[2])
            source.addLink(from: source.xOutput, to: target, targetSocket: target.inputs[3])
            source.addLink(from: source.yOutput, to: target, targetSocket: target.inputs[4])
            source.addLink(from: source.zOutput, to: target, targetSocket: target.inputs[5])
        }
        
        if let source = gyroNode.node as? GyroscopeNode, let target = zipNode.node as? ZipNode {
            source.addLink(from: source.pitchOutput, to: target, targetSocket: target.inputs[6])
            source.addLink(from: source.rollOutput, to: target, targetSocket: target.inputs[7])
            source.addLink(from: source.yawOutput, to: target, targetSocket: target.inputs[8])
            source.addLink(from: source.xRotOutput, to: target, targetSocket: target.inputs[9])
            source.addLink(from: source.yRotOutput, to: target, targetSocket: target.inputs[10])
            source.addLink(from: source.zRotOutput, to: target, targetSocket: target.inputs[11])
        }
        
        if let source = zipNode.node as? ZipNode, let target = bufferNode.node as? BufferNode {
            source.addLink(from: source.output, to: target, targetSocket: target.valuesInput)
        }
        
        if let source = classifierNode.node as? ExerciseClassifierNode, let target = printNode.node as? PrintNode {
            source.addLink(from: source.output, to: target, targetSocket: target.input)
        }
        
        if let source = bufferNode.node as? BufferNode, let target = classifierNode.node as? ExerciseClassifierNode {
            source.addLink(from: source.bufferOutput, to: target, targetSocket: target.input)
        }
    }
}

// MARK: - PanelSizeDelegate

extension ProjectViewController: PanelSizeDelegate {
    
    public func panel(_ panel: Panel, sizeForMode mode: Panel.Configuration.Mode) -> CGSize {
        func panelWidth(for position: Panel.Configuration.Position) -> CGFloat {
            if position == .bottom { return 0.0 }
            
            return traitCollection.userInterfaceIdiom == .pad ? 320.0 : 270.0
        }
        
        let width = panelWidth(for: panel.configuration.position)
        switch mode {
        case .minimal:
            return CGSize(width: width, height: 0.0)
        case .compact:
            return CGSize(width: width, height: 64.0)
        case .expanded:
            let height: CGFloat = traitCollection.userInterfaceIdiom == .phone ? 270.0 : 320.0
            return CGSize(width: width, height: height)
        case .fullHeight:
            return CGSize(width: width, height: 0.0)
        }
    }
}

// MARK: - PanelResizeDelegate

extension ProjectViewController: PanelResizeDelegate {
    
    public func panelDidStartResizing(_ panel: Panel) {
        // NOOP
    }
    
    public func panel(_ panel: Panel, willResizeTo size: CGSize) {
        // NOOP
    }
    
    public func panel(_ panel: Panel, willTransitionFrom oldMode: Panel.Configuration.Mode?, to newMode: Panel.Configuration.Mode, with coordinator: PanelTransitionCoordinator) {
        // NOOP
    }
}

// MARK: - PanelRepositionDelegate

extension ProjectViewController: PanelRepositionDelegate {
    
    public func panelDidStartMoving(_ panel: Panel) {
        // NOOP
    }
    
    public func panel(_ panel: Panel, shouldMoveTo frame: CGRect) -> Bool {
        return true
    }
    
    public func panel(_ panel: Panel, didStopMoving endFrame: CGRect, with context: PanelRepositionContext) -> PanelRepositionContext.Instruction {
        let panelShouldHide = context.isMovingPastLeadingEdge || context.isMovingPastTrailingEdge
        guard !panelShouldHide else { return .hide }
        
        return .updatePosition(context.targetPosition)
    }
    
    public func panel(_ panel: Panel, willTransitionFrom oldPosition: Panel.Configuration.Position, to newPosition: Panel.Configuration.Position, with coordinator: PanelTransitionCoordinator) {
        // NOOP
    }
    
    public func panelWillTransitionToHiddenState(_ panel: Panel, with coordinator: PanelTransitionCoordinator) {
        // NOOP
    }
}

extension ProjectViewController: NodeBrowserViewControllerDelegate {
    
    public func nodeBrowserViewController(_ controller: NodeBrowserViewController, spawnedNode: DisplayNode) {
        if let currentCanvasViewController = currentCanvasViewController {
            currentCanvasViewController.context.add(displayNode: spawnedNode)
        }
    }
}
