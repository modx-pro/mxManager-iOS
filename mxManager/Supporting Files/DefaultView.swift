//
//  DefaultView.swift
//  mxManager
//
//  Created by Василий Наумкин on 18.12.14.
//  Copyright (c) 2014 bezumkin. All rights reserved.
//

import UIKit
import Alamofire

class DefaultView: UIViewController {

	var data = [:]
	var AlamofireManager: Manager?

	func Request(parameters: [String:AnyObject], success: ((data:NSDictionary!) -> Void)?, failure: ((data:NSDictionary!) -> Void)?) {
		let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
		// Set timeout
		configuration.timeoutIntervalForResource = 10

		self.AlamofireManager = Alamofire.Manager(configuration: configuration)
		UIApplication.sharedApplication().networkActivityIndicatorVisible = true

		var request:[String:AnyObject] = [:]
		for (key, value) in parameters {
			request[key as String] = value
		}
		request["mx_version"] = MX_VERSION
		self.AlamofireManager!.request(.POST, self.data["manager"] as! String, parameters: request)
		.authenticate(user: self.data["base_user"] as! String, password: self.data["base_password"] as! String)
		.responseJSON {
			(request, response, result) in
			UIApplication.sharedApplication().networkActivityIndicatorVisible = false
			var data = [:]

			switch result {
				case .Success(let object):
					if success != nil {
						data = object as! NSDictionary
						let res = data["success"] as! Bool
						if res {
							success!(data: data)
						}
						else if failure != nil {
							failure!(data: data)
						}
					}
				case .Failure(_, _):
					if failure != nil {
						var message = ""
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
						failure!(data: data)
					}
			}
		}
	}

}
