//
//  CanvasViewController.swift
//  Wearvelop
//
//  Created by Philip Kluz on 2018-11-14.
//  Copyright © 2018 Philip Kluz. All rights reserved.
//

import UIKit

public final class CanvasViewController: UIViewController {

    // MARK: - UIViewController
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(canvasScrollView)
    }
    
    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        canvasScrollView.frame = view.bounds
    }
    
    // MARK: - CanvasViewController
    
    public init(title: String) {
        super.init(nibName: nil, bundle: nil)
        self.title = title
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public lazy var context: DisplayContext = {
        let view = DisplayContext(parentController: self, contentView: canvasScrollView)
        return view
    }()
    
    public lazy var canvasScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        scrollView.alwaysBounceHorizontal = true
        scrollView.showsVerticalScrollIndicator = true
        scrollView.showsHorizontalScrollIndicator = true
        scrollView.panGestureRecognizer.minimumNumberOfTouches = 2
        scrollView.backgroundColor = Color(red: 0.94, green: 0.94, blue: 0.94).systemColor
        return scrollView
    }()
}
