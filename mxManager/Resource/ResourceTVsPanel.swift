//
//  ResourceTVsPanel.swift
//  mxManager
//
//  Created by Василий Наумкин on 23.03.15.
//  Copyright (c) 2015 bezumkin. All rights reserved.
//

import UIKit

class ResourceTVsPanel: DefaultForm {

	var parent: ResourceTabPanel!

	 required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		name = "tvs"
	}

	override func viewDidLoad() {
		parent = self.parentViewController as! ResourceTabPanel
		super.viewDidLoad()
		self.parent.tvs_loaded = true

		self.loadData()
	}

	override func setFormValues(data: AnyObject) {
		let data = data as! NSArray
		let form: FormDescriptor = FormDescriptor()

		var current_category = ""
		for (idx, item) in (data as! [NSDictionary]).enumerate() {
			var section: FormSectionDescriptor
			let category = (item["category"] as? String) != nil
				? item["category"] as! String
				: ""
			if idx == 0 || category != current_category {
				section = FormSectionDescriptor()
				if category != "" {
					section.headerTitle = category
				}
				current_category = category
				form.addSection(section)
			}
			else {
				section = form.sections[form.sections.count - 1]
			}
			if idx == 0 && section.headerTitle != nil && self.tableHeaderView != nil {
				self.tableHeaderView!.backgroundColor = UIColor.whiteColor()
			}

			var params = NSMutableDictionary.init(dictionary: self.defaultParams)

			let field = item["field"] as! String
			let name = item["name"] as! String
			var required = false
			if let properties = item["properties"] as? NSDictionary {
				if properties["allowBlank"] != nil {
					required = properties["allowBlank"] as? Int == 0
				}
			}
			let tv_type = item["type"] as! String
			switch tv_type {
			case "textarea", "richtext":
				let row = FormRowDescriptor.init(tag: field, rowType: FormRowType.MultilineText, title: name) as FormRowDescriptor
				params["textField.font"] = UIFont.systemFontOfSize(self.defaultTextFontSize)
				row.configuration[FormRowDescriptor.Configuration.CellConfiguration] = params
				row.configuration[FormRowDescriptor.Configuration.Required] = required
				row.configuration[FormRowDescriptor.Configuration.CellHeight] = 88.0 as CGFloat
				row.configuration[FormRowDescriptor.Configuration.LabelWidth] = 125.0 as CGFloat
				row.value = item["value"] as? String
				section.addRow(row)
			break
			case "list-multiple-legacy", "listbox-multiple", "resourcelist",
				 "listbox", "option", "checkbox":
				let row = FormRowDescriptor.init(tag: field, rowType: FormRowType.MultipleSelector, title: name) as FormRowDescriptor
				params = NSMutableDictionary.init(dictionary: self.defaultParams)

				var multiple = false
				if let tmp = item["value"] as? NSArray {
					row.value = NSMutableArray.init(array: tmp)
					multiple = true
				}
				else {
					row.value = item["value"] as? String
				}

				let ids = [] as NSMutableArray
				let titles = [:] as NSMutableDictionary
				for element:String in (item["elements"] as! [String]) {
					let parts = element.componentsSeparatedByString("==")
					let value: String?
					let title: String?
					title = parts[0]
					value = parts.count > 1
						? parts[1]
						: title
					if title == nil || value == nil {
						continue
					}
					ids.addObject(value!)
					titles[value!] = title!
				}

				params["valueLabel.font"] = UIFont.systemFontOfSize(self.defaultTextFontSize)
				params["valueLabel.color"] = UIColor.blackColor()
				params["valueLabel.textAlignment"] = NSTextAlignment.Left.rawValue
				params["valueLabel.numberOfLines"] = 2
				row.configuration[FormRowDescriptor.Configuration.CellConfiguration] = params
				row.configuration[FormRowDescriptor.Configuration.Options] = ids
				row.configuration[FormRowDescriptor.Configuration.AllowsMultipleSelection] = multiple
				row.configuration[FormRowDescriptor.Configuration.Required] = required
				row.configuration[FormRowDescriptor.Configuration.LabelWidth] = 125.0 as CGFloat
				row.configuration[FormRowDescriptor.Configuration.TitleFormatterClosure] = {
					(value: AnyObject!) in
					if let value = value as? String {
						return titles[value] as? String
					}
					return nil
				} as TitleFormatterClosure

				section.addRow(row)
			case "date":
				let row = FormRowDescriptor.init(tag: field, rowType: FormRowType.DateAndTime, title: name) as FormRowDescriptor
				params["valueLabel.font"] = UIFont.systemFontOfSize(self.defaultTextFontSize)
				row.configuration[FormRowDescriptor.Configuration.CellConfiguration] = params
				row.configuration[FormRowDescriptor.Configuration.Required] = required
				row.configuration[FormRowDescriptor.Configuration.LabelWidth] = 125.0 as CGFloat
				if let value = item["value"] as? String {
					let formatter: NSDateFormatter = NSDateFormatter()
					formatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
					row.value = formatter.dateFromString(value)
				}
				else {
					row.value = nil
				}
				section.addRow(row)
			case "hidden":
				continue
			default:
				let type: FormRowType
				switch tv_type {
				case "url":
					type = .URL
					break
				case "number":
					type = .Number
					break
				case "email":
					type = .Email
					break
				default:
					type = .Text
				}
				let row = FormRowDescriptor.init(tag: field, rowType: type, title: name) as FormRowDescriptor
				params["textField.font"] = UIFont.systemFontOfSize(self.defaultTextFontSize)
				row.configuration[FormRowDescriptor.Configuration.CellConfiguration] = params
				row.configuration[FormRowDescriptor.Configuration.Required] = required
				row.configuration[FormRowDescriptor.Configuration.LabelWidth] = 125.0 as CGFloat
				row.value = item["value"] as? String
				section.addRow(row)
			}
		}

		self.form = form
		self.tableView.reloadData()
	}

	func loadData(spinner: Bool = true) {
		let request = [
				"mx_action": "resources/gettvs",
				"id": self.parent.id as NSNumber,
				"template": self.parent.template as NSNumber,
		]

		let spinner = spinner && self.navigationController!.visibleViewController?.isKindOfClass(ResourceTVsPanel) != nil
		if spinner {
			Utils.showSpinner(self.view)
		}
		parent.Request(request, success: {
			(data: NSDictionary!) in
			if spinner {
				Utils.hideSpinner(self.view)
			}
			self.setFormValues(data["data"] as! NSArray)
		}, failure: {
			(data: NSDictionary!) in
			Utils.hideSpinner(self.view)
			if spinner {
				Utils.alert("", message: data["message"] as! String, view: self, closure: {
					_ in
					self.parent.selectedIndex = 0
				})
			}
		})
	}

	override func submitForm(sender: UIBarButtonItem!) {
		self.parent.submitForm(sender)
	}

	override func addSaveButton() {
		self.parent.addSaveButton()
	}

	override func addHideKeyboardButton() {
		self.parent.addHideKeyboardButton()
	}

}
