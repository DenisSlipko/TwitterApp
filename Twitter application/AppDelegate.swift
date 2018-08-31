//
//  AppDelegate.swift
//  Twitter application
//
//  Created by Denis on 27.08.2018.
//  Copyright © 2018 Denis. All rights reserved.
//

import UIKit
import TwitterKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    private lazy var coreDataStack: CoreDataStack = CoreDataStack(modelName: "DataModel")
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        setupApplication()
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        return TWTRTwitter.sharedInstance().application(app, open: url, options: options)
    }
}

// MARK: - Setup Application
private extension AppDelegate {
    func setupApplication() {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = rootViewController
        window?.makeKeyAndVisible()
        setSharedCache()
        setupTwitter()
    }
    
    var rootViewController: UIViewController? {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateInitialViewController() as? ViewController ?? .init()
        let profileManager = ProfileManager(networkProvider: networkProvider,
                                            repository: repository)
        let authManager = AuthManager()
        controller.profileManager = profileManager
        controller.authManager = authManager
        let navigationController = UINavigationController(rootViewController: controller)
        return navigationController
    }
    
    var networkProvider: NetworkProvider {
        return NetworkService(
            baseURL: baseURL,
            decodingContext: coreDataStack.managedObjectContext
        )
    }
    
    var repository: CoreDataRepository<ManagedUserProfile> {
        return CoreDataRepository(context: coreDataStack.managedObjectContext)
    }
    
    var baseURL: URL {
        return URL(string: "https://api.twitter.com/1.1")!
    }
}

private extension AppDelegate {
    func setSharedCache() {
        let megabyte = 1024 * 1024
        let cache = URLCache(memoryCapacity: 100 * megabyte,
                             diskCapacity: 100 * megabyte,
                             diskPath: nil)
        URLCache.shared = cache
    }
    
    func setupTwitter() {
        TWTRTwitter.sharedInstance().start(
            withConsumerKey: Constants.Value.consumerKey,
            consumerSecret: Constants.Value.consumerSecret)
    }
}
