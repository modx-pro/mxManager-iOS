//
//  Site.swift
//  mxManager
//
//  Created by Василий Наумкин on 11.01.15.
//  Copyright (c) 2015 bezumkin. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

class Site: NSObject {

	var params = [:]

	init(params: NSDictionary) {
		self.params = params;
	}

	func clearCache(success: ((data:NSDictionary!) -> Void)?, failure: ((data:NSDictionary!) -> Void)?) {
		let parameters = [
				"mx_action": "main/clearcache"
		]
		self.Request(parameters, success, failure)
	}

	func getManagerLog(start: NSNumber = 0, success: ((data:NSDictionary!) -> Void)?, failure: ((data:NSDictionary!) -> Void)?) {
		let parameters = [
				"mx_action": "main/log/getlist",
				"start": start as NSNumber,
		]
		self.Request(parameters, success, failure)
	}

	func getResources(parent: NSNumber, start: NSNumber = 0, success: ((data:NSDictionary!) -> Void)?, failure: ((data:NSDictionary!) -> Void)?) {
		let parameters = [
				"mx_action": "resource/getlist",
				"parent": parent as NSNumber,
				"start": start as NSNumber,
		]
		self.Request(parameters, success, failure)
	}

	func Auth(success: ((data:NSDictionary!) -> Void)?, failure: ((data:NSDictionary!) -> Void)?) {
		let parameters = [
				"mx_action": "auth",
				"username": self.params["user"] as String,
				"password": self.params["password"] as String,
		]
		self.Request(parameters, success, failure)
	}

	func Request(parameters: [String:AnyObject], success: ((data:NSDictionary!) -> Void)?, failure: ((data:NSDictionary!) -> Void)?) {
		var configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
		// Set timeout
		configuration.timeoutIntervalForResource = 10

		let AlamofireManager = Alamofire.Manager(configuration: configuration)

		UIApplication.sharedApplication().networkActivityIndicatorVisible = true
		AlamofireManager.request(.GET, self.params["manager"] as String, parameters: parameters)
		.authenticate(user: self.params["base_user"] as String, password: self.params["base_password"] as String)
		.responseJSON {
			(request, response, object, error) in
			UIApplication.sharedApplication().networkActivityIndicatorVisible = false
			var data = [:]

			if success != nil && object != nil {
				data = object as NSDictionary
				let res = data["success"] as Bool
				if res {
					success?(data: data)
				}
				else if failure != nil {
					failure?(data: data)
				}
			}
			else if failure != nil {
				var message = "";
				if response == nil {
					message = "site_err_connect"
				}
				else if response?.statusCode == 401 && response?.allHeaderFields["Www-Authenticate"] != nil {
					message = "site_err_base_auth"
				}
				else {
					message = "site_err_no_manager"
				}
				data = [
					"success": 0,
					"message": message,
					"data": [:]
				]
				failure?(data: data)
			}
		}
	}

}
