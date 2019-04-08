//
//  AppDelegate.swift
//  Kakei
//
//  Created by IL KYOUNG HWANG on 2019/04/08.
//  Copyright © 2019 Sizuha. All rights reserved.
//

import UIKit
import SQuery

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?

	private func initDB() {
		setEnableSQueryDebug(true)
		
		// Create: App Support Dirctory (for DB storage)
		let path = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
		do {
			try FileManager.default.createDirectory(at: path, withIntermediateDirectories: true)
		} catch  {}
		
		let _ = KakeiDataManager.shared.createTables()
	}

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		
		self.window = UIWindow(frame: UIScreen.main.bounds)
		
		initDB()
		
		var viewControllers: [UIViewController] = []
		let vc = UIViewController()
		//vc.tabBarItem = UITabBarItem(title: <#T##String?#>, image: <#T##UIImage?#>, tag: <#T##Int#>)
		viewControllers.append(vc)
		
		let mainController = UITabBarController()
		mainController.setViewControllers(viewControllers, animated: false)
		
		self.window?.rootViewController = mainController
		self.window?.makeKeyAndVisible()
		
		return true
	}

	func applicationWillResignActive(_ application: UIApplication) {
		// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
		// Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
	}

	func applicationDidEnterBackground(_ application: UIApplication) {
		// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
		// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	}

	func applicationWillEnterForeground(_ application: UIApplication) {
		// Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
	}

	func applicationDidBecomeActive(_ application: UIApplication) {
		// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	}

	func applicationWillTerminate(_ application: UIApplication) {
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
	}

}

