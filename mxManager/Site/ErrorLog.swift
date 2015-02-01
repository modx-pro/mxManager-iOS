//
//  ErrorLog.swift
//  mxManager
//
//  Created by Василий Наумкин on 01.02.15.
//  Copyright (c) 2015 bezumkin. All rights reserved.
//

import UIKit

class ErrorLog: DefaultView {

	@IBOutlet var textLabel: UILabel?

	override func viewDidLoad() {
		super.viewDidLoad()

		self.refreshLog()
	}

	@IBAction func refreshLog() {
		let site = Site.init(params:self.data) as Site
		let parameters = [
			"mx_action": "main/errorlog/get"
		]

		Utils().showSpinner(self.view)
		site.Request(parameters, {
			data in
			Utils().hideSpinner(self.view)
			self.setLog(data["data"] as NSDictionary)
		}, {
			data in
			Utils().hideSpinner(self.view)
			Utils().alert("", message:data["message"] as String, view:self)
		})
	}

	@IBAction func clearLog() {
		let site = Site.init(params:self.data) as Site
		let parameters = [
				"mx_action": "main/errorlog/clear"
		]

		Utils().showSpinner(self.view)
		site.Request(parameters, {
			data in
			Utils().hideSpinner(self.view)
			self.setLog(data["data"] as NSDictionary)
		}, {
			data in
			Utils().hideSpinner(self.view)
			Utils().alert("", message:data["message"] as String, view:self)
		})
	}

	func setLog(data:NSDictionary) {
		if data["log"] != nil {
			var log:NSString
			if data["tooLarge"] as Bool {
				log = Utils().lexicon("error_log_too_large")
			}
			else {
				log = data["log"] as NSString
				log = log.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
				if log == "" {
					log = Utils().lexicon("error_log_empty")
				}
			}

			self.textLabel?.text = log
		}
	}

}
