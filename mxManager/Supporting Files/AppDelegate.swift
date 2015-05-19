//
//  AppDelegate.swift
//  mxManager
//
//  Created by Василий Наумкин on 17.12.14.
//  Copyright (c) 2014 bezumkin. All rights reserved.
//


import UIKit

let MX_VERSION = "1.0.0-pl"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {


	var window: UIWindow?


	func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject:AnyObject]?) -> Bool {
		// Check if we need to delete sites
		let defaults = NSUserDefaults.standardUserDefaults()

		let flag = defaults.objectForKey("mxManagerProtection") as? String
		if flag == nil {
			let sites = Utils.getSites()
			if sites.count > 0 {
				for site in sites {
					if let key = site["key"] as? String {
						Utils.removeSite(key, notify: false)
					}
				}
			}
			Utils.removePIN()
		}
		defaults.setObject("Yes", forKey: "mxManagerProtection")

		return true
	}


	func applicationWillResignActive(application: UIApplication) {
		// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
		// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.

	}


	func applicationDidEnterBackground(application: UIApplication) {
		// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
		// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.

	}


	func applicationWillEnterForeground(application: UIApplication) {
		// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
	}


	func applicationDidBecomeActive(application: UIApplication) {
		// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	}


	func applicationWillTerminate(application: UIApplication) {
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
	}


}


extension UINavigationController {
	public override func supportedInterfaceOrientations() -> Int {
		return visibleViewController.supportedInterfaceOrientations()
	}

	public override func shouldAutorotate() -> Bool {
		return visibleViewController.shouldAutorotate()
	}
}