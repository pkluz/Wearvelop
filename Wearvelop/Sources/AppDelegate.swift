//
//  AppDelegate.swift
//  Wearvelop
//
//  Created by Philip Kluz on 2018-11-12.
//  Copyright © 2018 Philip Kluz. All rights reserved.
//

import UIKit
import Parchment

@UIApplicationMain
public class AppDelegate: UIResponder, UIApplicationDelegate {

    // MARK: - UIApplicationDelegate

    public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // TODO: Project creation flow is not yet integrated. Creating a static project for now.
        let project = Project(id: nil, title: "My Project")
        let navigationController = UINavigationController(rootViewController: ProjectViewController(project: project))
        setupAppearance(for: navigationController)
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        
        return true
    }
    
    // MARK: - AppDelegate (Wearvelop)
    
    public var window: UIWindow?
    
    private func setupAppearance(for navigationController: UINavigationController) {
        navigationController.navigationBar.isTranslucent = false
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
        UINavigationBar.appearance().shadowImage = UIImage()
    }
}
