//
//  ElementPanel.swift
//  mxManager
//
//  Created by Василий Наумкин on 06.03.15.
//  Copyright (c) 2015 bezumkin. All rights reserved.
//

import UIKit

class ElementPanel: DefaultForm {

	var id = 0
	var category = 0
	var type = ""
	var action = "update"

	override func viewDidLoad() {
		super.viewDidLoad()

		let request = [
			"mx_action": "elements/" + self.type + "/get",
			"id": self.id as NSNumber,
		]

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

	override func setFormValues(data: AnyObject) {
		let data = data as! NSDictionary
		let form: FormDescriptor = FormDescriptor()

		var section: FormSectionDescriptor = FormSectionDescriptor()
		if data["name"] != nil {
			let row: FormRowDescriptor = FormRowDescriptor.init(tag: "name", rowType: FormRowType.Name, title: Utils.lexicon("element_name") as String)
			row.value = data["name"] as! String
			if row.value == "" {
				row.value = nil
			}
			let params = NSMutableDictionary.init(dictionary: self.defaultParams)
			params["textField.font"] = UIFont.systemFontOfSize(self.defaultTextFontSize)
			row.configuration[FormRowDescriptor.Configuration.CellConfiguration] = params
			row.configuration[FormRowDescriptor.Configuration.Required] = true
			section.addRow(row)
		}
		if self.type == "tv" && data["caption"] != nil {
			let row: FormRowDescriptor = FormRowDescriptor.init(tag: "caption", rowType: FormRowType.Name, title: Utils.lexicon("element_caption") as String)
			row.value = data["caption"] as! String
			let params = NSMutableDictionary.init(dictionary: self.defaultParams)
			params["textField.font"] = UIFont.systemFontOfSize(self.defaultTextFontSize)
			row.configuration[FormRowDescriptor.Configuration.CellConfiguration] = params
			section.addRow(row)
		}
		if data["description"] != nil {
			let row: FormRowDescriptor = FormRowDescriptor.init(tag: "description", rowType: FormRowType.MultilineText, title: Utils.lexicon("element_description") as String, height: 54)
			row.value = data["description"] as! String
			let params = NSMutableDictionary.init(dictionary: self.defaultParams)
			params["textField.font"] = UIFont.systemFontOfSize(self.defaultTextFontSize)
			row.configuration[FormRowDescriptor.Configuration.CellConfiguration] = params
			section.addRow(row)
		}

		if data["categories"] != nil {
			if let categories = data["categories"] as? NSArray {
				let row: FormRowDescriptor = FormRowDescriptor.init(tag: "category", rowType: FormRowType.MultipleSelector, title: Utils.lexicon("element_category") as String)
				let ids = [] as NSMutableArray
				let names = [:] as NSMutableDictionary
				for (_, item) in categories.enumerate() {
					if let id = item["id"] as? Int {
						if let name = item["name"] as? String {
							names[id] = name
							ids.addObject(id)
						}
					}
				}
				row.value = data["category"] as? Int
				if row.value == 0 && self.category != 0 && self.action == "create" {
					row.value = self.category
				}
				let params = NSMutableDictionary.init(dictionary: self.defaultParams)
				params["valueLabel.font"] = UIFont.systemFontOfSize(self.defaultTextFontSize)
				params["valueLabel.color"] = UIColor.blackColor()
				params["valueLabel.textAlignment"] = NSTextAlignment.Left.rawValue
				row.configuration[FormRowDescriptor.Configuration.CellConfiguration] = params
				row.configuration[FormRowDescriptor.Configuration.Options] = ids
				row.configuration[FormRowDescriptor.Configuration.AllowsMultipleSelection] = false
				row.configuration[FormRowDescriptor.Configuration.Required] = false
				row.configuration[FormRowDescriptor.Configuration.TitleFormatterClosure] = {
					(value: AnyObject!) in
					if let id = value as? Int {
						if let title = names[id] as? String {
							return title
						}
					}
					return nil
				} as TitleFormatterClosure
				section.addRow(row)
			}
		}

		for type in ["events", "templates"] {
			if let items = data[type] as? NSArray {
				let row: FormRowDescriptor = FormRowDescriptor.init(tag: type, rowType: FormRowType.MultipleSelector, title: Utils.lexicon("element_" + type) as String, height: 54)
				let ids = [] as NSMutableArray
				let names = [:] as NSMutableDictionary
				let enabled_items = [] as NSMutableArray
				for (_, item) in items.enumerate() {
					if let name = item["name"] as? String {
						if (type == "events") {
							if let group = item["group"] as? String {
								names[name] = "\(name)||\(group)"
							}
							else {
								names[name] = name
							}
							if item["enabled"] as? Int == 1 {
								enabled_items.addObject(name)
							}
							ids.addObject(name)
						}
						else {
							let id = item["id"] as! Int
							if let description = item["description"] as? String {
								names[id] = "\(name)||\(description)"
							}
							else {
								names[id] = name
							}
							if item["enabled"] as? Int == 1 {
								enabled_items.addObject(id)
							}
							ids.addObject(id)
						}
					}
				}
				row.value = enabled_items
				let params = NSMutableDictionary.init(dictionary: self.defaultParams)
				params["valueLabel.font"] = UIFont.systemFontOfSize(self.defaultTextFontSize)
				params["valueLabel.color"] = UIColor.blackColor()
				params["valueLabel.textAlignment"] = NSTextAlignment.Left.rawValue
				params["valueLabel.numberOfLines"] = 2
				row.configuration[FormRowDescriptor.Configuration.CellConfiguration] = params
				row.configuration[FormRowDescriptor.Configuration.Options] = ids
				row.configuration[FormRowDescriptor.Configuration.AllowsMultipleSelection] = true
				row.configuration[FormRowDescriptor.Configuration.Required] = false
				row.configuration[FormRowDescriptor.Configuration.TitleFormatterClosure] = {
					(value: AnyObject!) in
					if let name = value as? String {
						return names[name] as? String
					}
					else if let id = value as? Int {
						return names[id] as? String
					}
					return nil
				} as TitleFormatterClosure
				section.addRow(row)
			}
		}

		if self.type == "tv" {
			for (_, type) in ["type", "display"].enumerate() {
				if let items = data[type + "s"] as? NSArray {
					let row: FormRowDescriptor = FormRowDescriptor.init(tag: type, rowType: FormRowType.MultipleSelector, title: Utils.lexicon("element_" + type) as String)
					let ids = [] as NSMutableArray
					let names = [:] as NSMutableDictionary
					_ = [] as NSMutableArray
					for (_, item) in items.enumerate() {
						if item["value"] != nil && item["name"] != nil {
							let id = item["value"] as! String
							let name = item["name"] as! String
							names[id] = name
							ids.addObject(id)
						}
					}
					row.value = data[type] as? String
					if row.value != nil && row.value == "" {
						row.value = nil
					}
					let params = NSMutableDictionary.init(dictionary: self.defaultParams)
					params["valueLabel.font"] = UIFont.systemFontOfSize(self.defaultTextFontSize)
					params["valueLabel.color"] = UIColor.blackColor()
					params["valueLabel.textAlignment"] = NSTextAlignment.Left.rawValue
					row.configuration[FormRowDescriptor.Configuration.CellConfiguration] = params
					row.configuration[FormRowDescriptor.Configuration.Options] = ids
					row.configuration[FormRowDescriptor.Configuration.AllowsMultipleSelection] = false
					row.configuration[FormRowDescriptor.Configuration.Required] = true
					row.configuration[FormRowDescriptor.Configuration.TitleFormatterClosure] = {
						(value: AnyObject!) in
						if let id = value as? String {
							if let title = names[id] as? String {
								return title
							}
						}
						return nil
					} as TitleFormatterClosure
					section.addRow(row)
				}
			}
		}

		if self.type == "plugin" && data["disabled"] != nil {
			let row: FormRowDescriptor = FormRowDescriptor.init(tag: "disabled", rowType: FormRowType.BooleanSwitch, title: Utils.lexicon("element_disabled") as String)
			row.value = data["disabled"] as! Bool
			let params = NSMutableDictionary.init(dictionary: self.defaultParams)
			params["switchView.onTintColor"] = Colors.red()
			row.configuration[FormRowDescriptor.Configuration.CellConfiguration] = params
			section.addRow(row)
		}

		// Add main section
		form.sections.append(section)

		let lastHeight: CGFloat = 100
		section = FormSectionDescriptor()
		section.headerTitle = (self.type == "tv"
			? Utils.lexicon("element_default_value")
			: Utils.lexicon("element_content")) as String
		if data["content"] != nil {
			let decodedData = NSData.init(base64EncodedString: data["content"] as! String, options: [])
			if let decodedString = NSString.init(data: decodedData!, encoding: NSUTF8StringEncoding) {
				let type: FormRowType = decodedString.length > 30000 || self.type == "tv"
						? FormRowType.MultilineText
						: FormRowType.Code
				let row: FormRowDescriptor = FormRowDescriptor.init(tag: "content", rowType: type, title: "", height: lastHeight)
				row.value = decodedString
				let params = NSMutableDictionary.init(dictionary: self.defaultParams)
				params["textField.font"] = UIFont.init(name: "Courier New", size: self.defaultTextFontSize) as UIFont!
				row.configuration[FormRowDescriptor.Configuration.CellConfiguration] = params
				row.configuration[FormRowDescriptor.Configuration.Required] = false
				section.addRow(row)
				// Add content section
				form.sections.append(section)
			}
		}

		self.form = form
		self.tableView.reloadData()
		self.adjustLastRowHeight()
	}

	override func submitForm(sender: UIBarButtonItem!) {
		if let required = self.form.validateForm() {
			let message = Utils.lexicon("field_required", placeholders: ["field": required.title])
			Utils.alert("", message: message, view: self, closure: nil)
		}
		else {
			self.view.endEditing(true)
			let values = self.form.formValues()
			var request: [String:AnyObject] = [
					"mx_action": "elements/\(self.type)/\(self.action)",
					"id": self.id as NSNumber
			]

			for (key, value) in values {
				if (key as! String) == "content" {
					var content = ""
					if let plainData = (value as! NSString).dataUsingEncoding(NSUTF8StringEncoding) {
						content = plainData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.init(rawValue: 0))
					}
					request["content"] = content
				}
				else {
					request[key as! String] = value
				}
			}
			//Utils.alert("Form data", message: request.description, view: self, closure: nil)

			Utils.showSpinner(self.view)
			self.Request(request, success: {
				(data: NSDictionary!) in
				Utils.hideSpinner(self.view)

				self.title = values["name"] as? String
				if let response = data["data"] as? NSDictionary {
					self.id = response["id"] as! Int
					if self.action == "create" {
						self.action = "update"
					}
					self.setFormValues(response)
					NSNotificationCenter.defaultCenter().postNotificationName("ElementUpdated", object: response)
				}
			}, failure: {
				(data: NSDictionary!) in
				Utils.hideSpinner(self.view)
				Utils.alert("", message: data["message"] as! String, view: self)
			})
		}
	}

}
