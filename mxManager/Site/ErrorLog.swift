//
//  ErrorLog.swift
//  mxManager
//
//  Created by Василий Наумкин on 01.02.15.
//  Copyright (c) 2015 bezumkin. All rights reserved.
//

import UIKit

class ErrorLog: DefaultView {

	@IBOutlet var textView: UITextView!
	var refreshBtn: UIBarButtonItem?
	var clearBtn: UIBarButtonItem?

	override func viewDidLoad() {
		super.viewDidLoad()
		self.addRightButtons()

		self.refreshLog()
	}

	func addRightButtons() {
		self.refreshBtn = UIBarButtonItem.init(image: UIImage.init(named: "icon-refresh"), style: UIBarButtonItemStyle.Plain, target: self, action: "refreshLog")
		self.clearBtn = UIBarButtonItem.init(image: UIImage.init(named: "icon-trash"), style: UIBarButtonItemStyle.Plain, target: self, action: "clearLog")

		self.navigationItem.setRightBarButtonItems([self.refreshBtn!, self.clearBtn!], animated: false)
	}

	func refreshLog() {
		let parameters = [
				"mx_action": "main/errorlog/get"
		]

		Utils.showSpinner(self.view)
		self.Request(parameters, success: {
			(data: NSDictionary!) in
			Utils.hideSpinner(self.view)
			self.setLog(data["data"] as! NSDictionary)
		}, failure: {
			(data: NSDictionary!) in
			Utils.hideSpinner(self.view)
			Utils.alert("", message: data["message"] as! String, view: self)
		})
	}

	func clearLog() {
		let parameters = [
				"mx_action": "main/errorlog/clear"
		]

		Utils.confirm("", message: "error_log_clear_confirm" as String, view: self, closure: {
			_ in
			Utils.showSpinner(self.view)
			self.Request(parameters, success: {
				(data: NSDictionary!) in
				Utils.hideSpinner(self.view)
				self.setLog(data["data"] as! NSDictionary)
			}, failure: {
				(data: NSDictionary!) in
				Utils.hideSpinner(self.view)
				Utils.alert("", message: data["message"] as! String, view: self)
			})
		})
	}

	func setLog(data: NSDictionary) {
		if data["log"] != nil {
			var log = ""

			if data["tooLarge"] as! Bool {
				log = Utils.lexicon("error_log_too_large") as String
			}
			else {
				let decodedData = NSData.init(base64EncodedString: data["log"] as! String, options: [])
				if let decodedString: NSString = NSString.init(data: decodedData!, encoding: NSUTF8StringEncoding) {
					log = decodedString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
					self.clearBtn?.enabled = true
				}
				if log == "" {
					log = Utils.lexicon("error_log_empty") as String
					self.clearBtn?.enabled = false
				}
			}

			self.textView.text = log
		}
	}

}
