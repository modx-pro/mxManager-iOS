//
//  ResourceTabPanel.swift
//  mxManager
//
//  Created by Василий Наумкин on 23.03.15.
//  Copyright (c) 2015 bezumkin. All rights reserved.
//

import UIKit

class ResourceTabPanel: UITabBarController {

	var hideKeyboardBtn: UIBarButtonItem?
	var saveBtn: UIBarButtonItem?
	var previewBtn: UIBarButtonItem?
	var tabs: [String:DefaultForm] = [:]

	var data = [:]
	var item = [:]
	var id = 0

	var action = "update"
	var class_key = "modDocument"
	var context = "web"
	var parent = 0
	var template = 0
	var tvs = false
	var tvs_loaded = false
	var defaultView: DefaultView?

	override func viewDidLoad() {
		super.viewDidLoad()
		self.navigationItem.backBarButtonItem = UIBarButtonItem.init(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
		self.tabBar.tintColor = Colors.defaultText()

		self.loadData()
	}

	func Request(parameters: [String:AnyObject], success: ((data:NSDictionary!) -> Void)?, failure: ((data:NSDictionary!) -> Void)?) {
		self.defaultView = DefaultView()
		self.defaultView!.data = self.data
		self.defaultView!.Request(parameters, success: success, failure: failure)
	}

	func loadData() {
		var request = [
				"mx_action": "resources/get",
				"id": self.id as NSNumber,
		]
		if self.id == 0 {
			request["class_key"] = self.class_key as NSString
			request["context_key"] = self.context as NSString
			request["parent"] = self.parent as NSNumber
		}

		Utils.showSpinner(self.view)
		self.Request(request, success: {
			(data: NSDictionary!) in
			Utils.hideSpinner(self.view)
			self.setFormValues(data["data"] as! NSDictionary)
		}, failure: {
			(data: NSDictionary!) in
			Utils.hideSpinner(self.view)
			Utils.alert("", message: data["message"] as! String, view: self, closure: {
				_ in
				self.performSegueWithIdentifier("ExitView", sender: nil)
			})
		})
	}

	func setFormValues(data: NSDictionary) {
		let data = NSMutableDictionary.init(dictionary: data)
		data["class_key"] = self.class_key
		self.item = data

		self.previewBtn?.enabled = false
		if let preview = data["preview_url"] as? String {
			if preview != "" {
				self.previewBtn?.enabled = true
			}
		}

		if let permissions = data["permissions"] as? NSDictionary {
			self.saveBtn?.enabled = permissions["save"] as! Bool
		}

		if self.viewControllers != nil {
			for (key, item) in self.viewControllers!.enumerate() {
				if let tab = item as? DefaultForm {
					if tab.name == "tvs" {
						if let tvs = data["tvs"] as? Bool {
							self.activateTVsTab(tvs)
						}
						else {
							self.activateTVsTab(false)
						}
					}
					else {
						tab.setFormValues(data)
						if tab.form.sections.count == 0 && self.tabBar.items != nil {
							let btn = self.tabBar.items![key]
							btn.enabled = false
						}
					}
					self.tabs[tab.name] = tab
				}
			}
		}
		if let template = data["template"] as? Int {
			self.template = template
		}
	}

	func getFormValues() -> NSDictionary {
		let values = [:] as NSMutableDictionary

		if self.viewControllers != nil {
			for item in self.viewControllers! {
				if let tab = item as? DefaultForm {
					if tab.name == "tvs" && self.tvs == false {
						continue
					}
					if tab.form != nil {
						if let required = tab.form.validateForm() {
							let message = Utils.lexicon(
							"field_required",
							placeholders: [
									"field": Utils.lexicon("resource_" + required.tag) as String
							])
							Utils.alert("", message: message, view: self, closure: nil)
							return [:]
						}
						else {
							let tmp = tab.getFormValues()
							for (key, value) in tmp {
								values[key as! String] = value
							}
						}
					}
				}
			}
		}
		values["tvs"] = self.tvs && self.tvs_loaded
		values["context_key"] = self.context

		return values
	}

	func submitForm(sender: UIBarButtonItem!) {
		let values = self.getFormValues()
		if values.count > 0 {
			self.view.endEditing(true)
			var request: [String:AnyObject] = [
					"mx_action": "resources/\(self.action)",
					"id": self.id as NSNumber
			]

			for (key, value) in values {
				request[key as! String] = value
			}
			//Utils.alert("Form data", message: request.description, view: self, closure: nil)

			Utils.showSpinner(self.view)
			self.Request(request, success: {
				(data: NSDictionary!) in
				Utils.hideSpinner(self.view)

				self.title = values["pagetitle"] as? String
				if let response = data["data"] as? NSDictionary {
					self.id = response["id"] as! Int
					if self.action == "create" {
						self.action = "update"
					}
					self.setFormValues(response)
					NSNotificationCenter.defaultCenter().postNotificationName("ResourceUpdated", object: response)
				}
			}, failure: {
				(data: NSDictionary!) in
				Utils.hideSpinner(self.view)
				Utils.alert("", message: data["message"] as! String, view: self)
			})
		}
	}

	func viewItem(sender: UIBarButtonItem!) {
		if let preview = self.item["preview_url"] as? String {
			if preview != "" {
				let url = NSURL.init(string: preview)
				UIApplication.sharedApplication().openURL(url!)
			}
		}
	}

	func finishEdit(sender: UIBarButtonItem!) {
		self.view.endEditing(true)
	}

	func addSaveButton() {
		if self.saveBtn == nil {
			self.saveBtn = UIBarButtonItem.init(image: UIImage.init(named: "icon-check"), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(ResourceTabPanel.submitForm(_:)))
			self.saveBtn!.enabled = false
		}
		if self.previewBtn == nil {
			self.previewBtn = UIBarButtonItem.init(image: UIImage.init(named: "icon-eye"), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(ResourceTabPanel.viewItem(_:)))
			self.previewBtn!.enabled = false
		}

		self.navigationItem.setRightBarButtonItems([self.saveBtn!, self.previewBtn!], animated: false)
	}

	func addHideKeyboardButton() {
		if self.hideKeyboardBtn == nil {
			self.hideKeyboardBtn = UIBarButtonItem.init(image: UIImage.init(named: "icon-keyboard-hide"), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(ResourceTabPanel.finishEdit(_:)))
		}

		self.navigationItem.setRightBarButtonItems([self.hideKeyboardBtn!], animated: false)
	}

	func activateTVsTab(enabled: Bool) {
		self.tvs = enabled
		for (key, item) in self.viewControllers!.enumerate() {
			if let tab = item as? DefaultForm where tab.name == "tvs" {
				if self.tabBar.items != nil {
					let btn = self.tabBar.items![key]
					btn.enabled = enabled
				}
				break
			}
		}
	}

}
