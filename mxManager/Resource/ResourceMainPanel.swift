//
//  ResourceMainPanel.swift
//  mxManager
//
//  Created by Василий Наумкин on 23.03.15.
//  Copyright (c) 2015 bezumkin. All rights reserved.
//

import UIKit

class ResourceMainPanel: DefaultForm {

	var parent: ResourceTabPanel!

	 required init(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		name = "main"
	}

	override func viewDidLoad() {
		parent = self.parentViewController as! ResourceTabPanel
		super.viewDidLoad()
	}

	override func setFormValues(data: AnyObject) {
		let data = data as! NSDictionary
		let form: FormDescriptor = FormDescriptor()

		if self.tableHeaderView != nil {
			self.tableHeaderView!.backgroundColor = UIColor.whiteColor()
		}

		var params = NSMutableDictionary.init(dictionary: self.defaultParams)
		params["textField.font"] = UIFont.systemFontOfSize(self.defaultTextFontSize)

		for field in ["pagetitle", "longtitle"] {
			if data[field] != nil {
				let section: FormSectionDescriptor = FormSectionDescriptor()
				section.headerTitle = Utils.lexicon("resource_" + field) as String
				let row = FormRowDescriptor.init(tag: field, rowType: FormRowType.Name, title: "") as FormRowDescriptor
				row.configuration[FormRowDescriptor.Configuration.CellConfiguration] = params
				row.configuration[FormRowDescriptor.Configuration.Required] = field == "pagetitle"
				row.value = data[field] as? String
				section.addRow(row)
				form.addSection(section)
			}
		}

		let section: FormSectionDescriptor = FormSectionDescriptor()
		for field in ["alias", "menutitle", "link_attributes"] {
			if data[field] != nil {
				let row = FormRowDescriptor.init(tag: field, rowType: FormRowType.Name, title: Utils.lexicon("resource_" + field) as String) as FormRowDescriptor
				row.configuration[FormRowDescriptor.Configuration.Required] = false
				row.value = data[field] as! String
				row.configuration[FormRowDescriptor.Configuration.CellConfiguration] = params
				row.configuration[FormRowDescriptor.Configuration.LabelWidth] = 125.0 as CGFloat
				section.addRow(row)
			}
		}
		for field in ["published", "hidemenu"] {
			var tmp_params = NSMutableDictionary.init(dictionary: self.defaultParams)
			if data[field] != nil {
				let row = FormRowDescriptor.init(tag: field, rowType: FormRowType.BooleanSwitch, title: Utils.lexicon("resource_" + field) as String) as FormRowDescriptor
				tmp_params["switchView.onTintColor"] = field == "hidemenu"
					? Colors.red()
					: Colors.green()
				row.configuration[FormRowDescriptor.Configuration.CellConfiguration] = tmp_params
				row.configuration[FormRowDescriptor.Configuration.Required] = false
				row.configuration[FormRowDescriptor.Configuration.LabelWidth] = 125.0 as CGFloat
				row.value = data[field] as? Bool
				section.addRow(row)
			}
		}
		if section.rows.count > 0 {
			form.addSection(section)
		}

		for field in ["description", "introtext", "content"] {
			if data[field] != nil {
				let section: FormSectionDescriptor = FormSectionDescriptor()
				if field == "content" {
					switch self.parent.class_key {
					case "modSymLink", "modWebLink", "modStaticResource":
						section.headerTitle = Utils.lexicon(self.parent.class_key)
						break
					default:
						section.headerTitle = Utils.lexicon("resource_content")
					}
				}
				else {
					section.headerTitle = Utils.lexicon("resource_" + field)
				}
				var row: FormRowDescriptor
				var value = ""
				let decodedData = NSData.init(base64EncodedString: data[field] as! String, options: nil)
				if let decodedString = NSString.init(data: decodedData!, encoding: NSUTF8StringEncoding) {
					value = decodedString as String
				}
				if field == "content" {
					row = self.getContentRow(value)
				}
				else {
					row = FormRowDescriptor.init(tag: field, rowType: FormRowType.MultilineText, title: "") as FormRowDescriptor
					row.configuration[FormRowDescriptor.Configuration.CellConfiguration] = params
					row.configuration[FormRowDescriptor.Configuration.CellHeight] = 66.0 as CGFloat
					row.configuration[FormRowDescriptor.Configuration.Required] = false
					row.value = value
				}
				section.addRow(row)
				form.addSection(section)
			}
		}

		self.form = form
		self.tableView.reloadData()
		if find(["modWebLink", "modSymLink", "modStaticResource"], self.parent.class_key) == nil {
			self.adjustLastRowHeight(minHeight: 200)
		}
	}

	func getContentRow(content: AnyObject?) -> FormRowDescriptor {
		var configuration: [NSObject: Any] = [:]
		var params = NSMutableDictionary.init(dictionary: self.defaultParams)
		params["textField.font"] = UIFont.systemFontOfSize(self.defaultTextFontSize)

		var height: CGFloat
		var rowType: FormRowType

		switch self.parent.class_key {
		case "modWebLink":
			height = 66
			self.wasAdjusted = false
			rowType = .URL
			break
		case "modSymLink":
			height = 66
			self.wasAdjusted = false
			rowType = .Number
			break
		case "modStaticResource":
			height = 66
			self.wasAdjusted = false
			rowType = .Name
		default:
			height = 200
			self.wasAdjusted = true
			rowType = .MultilineText
		}

		let row = FormRowDescriptor.init(tag: "content", rowType: rowType, title: "") as FormRowDescriptor
		configuration[FormRowDescriptor.Configuration.CellConfiguration] = params
		configuration[FormRowDescriptor.Configuration.CellHeight] = height as CGFloat
		row.configuration = configuration
		row.value = content as? String

		return row
	}

	override func getFormValues() -> NSDictionary {
		var data = NSMutableDictionary.init(dictionary: super.getFormValues())

		for field in ["description", "introtext", "content"] {
			if data[field] != nil {
				if let plainData = (data[field] as! NSString).dataUsingEncoding(NSUTF8StringEncoding) {
					data[field] = plainData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.init(0))
				}
			}
		}

		return data
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
