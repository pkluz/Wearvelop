//
//  NodeBrowserViewController.swift
//  Wearvelop
//
//  Created by Philip Kluz on 2018-12-02.
//  Copyright © 2018 Philip Kluz. All rights reserved.
//

import UIKit

public protocol NodeBrowserViewControllerDelegate: class {
    func nodeBrowserViewController(_ controller: NodeBrowserViewController, spawnedNode: DisplayNode)
}

public final class NodeBrowserViewController: UITableViewController {
    
    // MARK: - NSObject
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIViewController
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Node Browser"
        tableView.estimatedRowHeight = 75.0
        view.backgroundColor = .white
        tableView.separatorInset = .zero
        tableView.separatorStyle = .none
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
        tableView.register(UINib(nibName: "NodeTableViewCell", bundle: nil), forCellReuseIdentifier: "NodeTableViewCell")
    }
    
    // MARK: - NodeBrowserViewController
    
    public init() {
        super.init(style: .plain)
    }
    
    public weak var delegate: NodeBrowserViewControllerDelegate?
    
    private let nodes: [NodeDescriptor] = NodeDescriptor.allCases.sorted { $0.title < $1.title }
    
    private func createNode(with descriptor: NodeDescriptor) {
        if descriptor == .constant {
            beginCreatingConstantNode(with: descriptor)
        } else if descriptor == .buffer {
            beginCreatingBufferNode(with: descriptor)
        } else if descriptor == .ringBuffer {
            beginCreatingRingBufferNode(with: descriptor)
        } else if descriptor == .timer {
            beginCreatingTimerNode(with: descriptor)
        } else if descriptor == .combineLatest {
            beginCreatingCombineLatestNode(with: descriptor)
        } else if descriptor == .chart {
            beginCreatingChartNode(with: descriptor)
        } else if descriptor == .javaScript {
            beginCreatingJavaScriptNode(with: descriptor)
        } else if descriptor == .zip {
            beginCreatingZipNode(with: descriptor)
        } else if let displayNode = descriptor.build(with: nil) {
            delegate?.nodeBrowserViewController(self, spawnedNode: displayNode)
        }
    }
    
    private func beginCreatingConstantNode(with descriptor: NodeDescriptor) {
        let controller = UIAlertController(title: "Constant Node", message: "Please enter a value", preferredStyle: .alert)
        let add = UIAlertAction(title: "Add", style: .default) { [weak controller, weak self] action in
            guard let textField = controller?.textFields?.first, let value = textField.text, !value.isEmpty else { return }
            self?.createConstantNode(with: value)
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .destructive) { _ in }
        controller.addTextField { (textField) in
            textField.placeholder = "Constant Value"
        }
        controller.addAction(cancel)
        controller.addAction(add)
        present(controller, animated: true, completion: nil)
    }
    
    private func createConstantNode(with stringValue: String) {
        let displayNode = ConstantDisplayNode(value: stringValue.toCastValue())
        delegate?.nodeBrowserViewController(self, spawnedNode: displayNode)
    }
    
    private func beginCreatingBufferNode(with descriptor: NodeDescriptor) {
        let controller = UIAlertController(title: "Buffer Node", message: "Please enter the desired ring buffer capacity", preferredStyle: .alert)
        let add = UIAlertAction(title: "Add", style: .default) { [weak controller, weak self] action in
            guard let textField = controller?.textFields?.first, let value = textField.text, !value.isEmpty else { return }
            self?.createBufferNode(with: value)
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .destructive) { _ in }
        controller.addTextField { (textField) in
            textField.placeholder = "Buffer Value"
        }
        controller.addAction(cancel)
        controller.addAction(add)
        present(controller, animated: true, completion: nil)
    }
    
    private func createBufferNode(with sizeStringValue: String) {
        guard let size: Int = sizeStringValue.toCastValue().unwrapAsInt() else  { return }
        let node = DisplayNode(node: BufferNode(size: size))
        delegate?.nodeBrowserViewController(self, spawnedNode: node)
    }
    
    private func beginCreatingCombineLatestNode(with descriptor: NodeDescriptor) {
        let controller = UIAlertController(title: "Combine Latest Node", message: "Please enter the desired arity", preferredStyle: .alert)
        let add = UIAlertAction(title: "Add", style: .default) { [weak controller, weak self] action in
            guard let textField = controller?.textFields?.first, let value = textField.text, !value.isEmpty else { return }
            self?.createCombineLatestNode(with: value)
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .destructive) { _ in }
        controller.addTextField { (textField) in
            textField.placeholder = "Arity Value"
        }
        controller.addAction(cancel)
        controller.addAction(add)
        present(controller, animated: true, completion: nil)
    }
    
    private func createCombineLatestNode(with sizeStringValue: String) {
        let maybeSize = sizeStringValue.toCastValue().unwrapAsInt()
        if let size = maybeSize {
            let node = DisplayNode(node: CombineLatestNode(inputs: size))
            delegate?.nodeBrowserViewController(self, spawnedNode: node)
        }
    }
    
    private func beginCreatingChartNode(with descriptor: NodeDescriptor) {
        let controller = UIAlertController(title: "Chart Node", message: "Please enter the desired arity", preferredStyle: .alert)
        let add = UIAlertAction(title: "Add", style: .default) { [weak controller, weak self] action in
            guard let textField = controller?.textFields?.first, let value = textField.text, !value.isEmpty else { return }
            self?.createChartNode(with: value)
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .destructive) { _ in }
        controller.addTextField { (textField) in
            textField.placeholder = "Arity Value"
        }
        controller.addAction(cancel)
        controller.addAction(add)
        present(controller, animated: true, completion: nil)
    }
    
    private func createChartNode(with arityStringValue: String) {
        let maybeArity = arityStringValue.toCastValue().unwrapAsInt()
        if let arity = maybeArity {
            let node = ChartDisplayNode(capacity: 205, inputs: arity)
            delegate?.nodeBrowserViewController(self, spawnedNode: node)
        }
    }
    
    private func beginCreatingJavaScriptNode(with descriptor: NodeDescriptor) {
        let controller = UIAlertController(title: "JavaScript Node", message: "Please enter the desired number of arguments", preferredStyle: .alert)
        let add = UIAlertAction(title: "Add", style: .default) { [weak controller, weak self] action in
            guard let textField = controller?.textFields?.first, let value = textField.text, !value.isEmpty else { return }
            self?.createJavaScriptNode(with: value)
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .destructive) { _ in }
        controller.addTextField { (textField) in
            textField.placeholder = "Argument Count"
        }
        controller.addAction(cancel)
        controller.addAction(add)
        present(controller, animated: true, completion: nil)
    }
    
    private func createJavaScriptNode(with arityStringValue: String) {
        let maybeArity = arityStringValue.toCastValue().unwrapAsInt()
        if let arity = maybeArity {
            let node = DisplayNode(node: JavaScriptNode(with: arity))
            delegate?.nodeBrowserViewController(self, spawnedNode: node)
        }
    }
    
    private func beginCreatingZipNode(with descriptor: NodeDescriptor) {
        let controller = UIAlertController(title: "Zip Node", message: "Please enter the desired number of inputs", preferredStyle: .alert)
        let add = UIAlertAction(title: "Add", style: .default) { [weak controller, weak self] action in
            guard let textField = controller?.textFields?.first, let value = textField.text, !value.isEmpty else { return }
            self?.createZipNode(with: value)
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .destructive) { _ in }
        controller.addTextField { (textField) in
            textField.placeholder = "Input Value"
        }
        controller.addAction(cancel)
        controller.addAction(add)
        present(controller, animated: true, completion: nil)
    }
    
    private func createZipNode(with arityStringValue: String) {
        let maybeArity = arityStringValue.toCastValue().unwrapAsInt()
        if let arity = maybeArity {
            let node = DisplayNode(node: ZipNode(inputs: arity))
            delegate?.nodeBrowserViewController(self, spawnedNode: node)
        }
    }
    
    private func beginCreatingRingBufferNode(with descriptor: NodeDescriptor) {
        let controller = UIAlertController(title: "Ring Buffer Node", message: "Please enter the desired ring buffer capacity", preferredStyle: .alert)
        let add = UIAlertAction(title: "Add", style: .default) { [weak controller, weak self] action in
            guard let textField = controller?.textFields?.first, let value = textField.text, !value.isEmpty else { return }
            self?.createRingBufferNode(with: value)
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .destructive) { _ in }
        controller.addTextField { (textField) in
            textField.placeholder = "Ring Buffer Value"
        }
        controller.addAction(cancel)
        controller.addAction(add)
        present(controller, animated: true, completion: nil)
    }
    
    private func createRingBufferNode(with sizeStringValue: String) {
        guard let capacity = sizeStringValue.toValue().unwrapAsInt() else { return }
        let ringBufferDisplayNode = DisplayNode(node: RingBufferNode(capacity: capacity))
        delegate?.nodeBrowserViewController(self, spawnedNode: ringBufferDisplayNode)
    }
    
    private func beginCreatingTimerNode(with descriptor: NodeDescriptor) {
        let controller = UIAlertController(title: "Timer Node", message: "Please enter the desired fire frequency in seconds", preferredStyle: .alert)
        let add = UIAlertAction(title: "Add", style: .default) { [weak controller, weak self] action in
            guard let textField = controller?.textFields?.first, let value = textField.text, !value.isEmpty else { return }
            self?.createTimerNode(with: value)
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .destructive) { _ in }
        controller.addTextField { (textField) in
            textField.placeholder = "Time in Seconds"
        }
        controller.addAction(cancel)
        controller.addAction(add)
        present(controller, animated: true, completion: nil)
    }
    
    private func createTimerNode(with sizeStringValue: String) {
        let interval: TimeInterval = sizeStringValue.toCastValue().unwrapAsDouble() ?? 1.0
        let timerDisplayNode = DisplayNode(node: TimerNode(interval: interval))
        delegate?.nodeBrowserViewController(self, spawnedNode: timerDisplayNode)
    }
    
    // MARK: - UITableViewDataSource
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nodes.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let maybeNode = nodes[safe: indexPath.row]
        if let cell = tableView.dequeueReusableCell(withIdentifier: "NodeTableViewCell", for: indexPath) as? NodeTableViewCell, let node = maybeNode {
            cell.titleLabel.text = node.title
            cell.subtitleLabel.text = node.subtitle
            cell.iconImageView.image = node.image
            return cell
        }
        
        return tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)
    }
    
    // MARK: - UITableViewDelegate
    
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let node = nodes[safe: indexPath.row] {
            createNode(with: node)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
