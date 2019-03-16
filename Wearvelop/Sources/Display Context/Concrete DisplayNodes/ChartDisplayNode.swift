//
//  ChartDisplayNode.swift
//  Wearvelop
//
//  Created by Philip Kluz on 2019-02-11.
//  Copyright © 2019 Philip Kluz. All rights reserved.
//

import UIKit
import AAInfographics

/// `ChartDisplayNode` is a customized version of `DisplayNode` because
/// it requires a larger frame and some additional subviews to work.
public class ChartDisplayNode: DisplayNode {
    
    // MARK: - NSObject
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIView
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        chartContainerView.frame = frameForChartView()
        chartView.frame = chartContainerView.bounds
    }
    
    // MARK: - NodeDelegate
    
    public override func nodeChanged(_ node: Node) {
        super.nodeChanged(node)
        
        if let node = node as? ChartNode {
            var buffers: [[Double]] = []
            for input in node.inputs {
                if let buffer = node.buffer(for: input) {
                    let result = buffer.map({ $0.unwrapAsDouble() }).compactMap({ $0 })
                    if !result.isEmpty {
                        buffers.append(result)
                    }
                }
            }
            
            let data = series(with: buffers)
            chartView.aa_onlyRefreshTheChartDataWithChartModelSeries(data)
        }
    }
    
    // MARK: - ChartDisplayNode
    
    public init(capacity: Int, inputs: Int) {
        let node = ChartNode(capacity: capacity, inputs: inputs)
        var frame = DisplayNode.frame(for: node)
        frame.size.width = max(frame.width, 340.0)
        frame.size.height = frame.height + 180.0
        super.init(frame: frame, node: node)
        node.delegate = self
        addSubview(chartContainerView)
        
        chartView.aa_drawChartWithChartModel(chartModel)
    }
    
    private func frameForChartView() -> CGRect {
        let lastSocketFrame = frameForSocket(atIndex: max(max(socketInputViews.count, socketOutputViews.count) - 1, 0), horizontalOffset: 0.0, verticalOffset: titleDivider.frame.maxY + DisplayNodeConstants.socketTopBottomSpacing)
        return CGRect(x: DisplayNodeConstants.socketLeadingTrailingSpacing,
                      y: lastSocketFrame.maxY + DisplayNodeConstants.socketTopBottomSpacing,
                      width: bounds.width - (DisplayNodeConstants.socketLeadingTrailingSpacing * 2.0),
                      height: bounds.height - lastSocketFrame.maxY - (DisplayNodeConstants.socketTopBottomSpacing * 2.0))
    }
    
    public lazy var chartContainerView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = Color(red: 0.93, green: 0.93, blue: 0.93).systemColor
        view.layer.cornerRadius = 6.0
        view.addSubview(chartView)
        return view
    }()
    
    public lazy var chartView: AAChartView = {
        let view = AAChartView()
        view.isClearBackgroundColor = true
        view.layer.cornerRadius = 3.0
        view.layer.masksToBounds = true
        view.scrollEnabled = false
        view.isUserInteractionEnabled = false
        return view
    }()
    
    public lazy var chartModel: AAChartModel = {
        let emptySeries: [[String: Any]] = self.node.inputs.map { _ in return [:] }
        
        let model = AAChartModel()
            .chartType(AAChartType.line)
            .animationDuration(0)
            .animationType(AAChartAnimationType.easeInQuad)
            .title("")
            .subtitle("")
            .series(emptySeries)
            .dataLabelEnabled(false)
            .xAxisVisible(false)
            .xAxisLabelsEnabled(false)
            .yAxisLabelsEnabled(false)
            .yAxisGridLineWidth(1.0)
            .markerRadius(0)
            .legendEnabled(false)
            .tooltipEnabled(false)
            .tooltipCrosshairs(false)
        
        return model
    }()
    
    private func series(with dataSets: [[Double]]) -> [[String : AnyObject]] {
        return dataSets.map { data -> [String : AnyObject] in
            return AASeriesElement()
                .lineWidth(1.0)
                .allowPointSelect(false)
                .data(data)
                .step("center")
                .toDic()!
        }
    }
}
