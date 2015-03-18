//
//  FilePanel.swift
//  mxManager
//
//  Created by Василий Наумкин on 26.02.15.
//  Copyright (c) 2015 bezumkin. All rights reserved.
//

import UIKit

class FilePanel: DefaultForm {

	var file = [:]
	var source = 0
	var path = ""
	var pathRelative = ""
	var action = "update"

	override func viewDidLoad() {
		super.viewDidLoad()

		if self.action == "create" {
			self.setForm([
				"image": false,
				"content": "",
				"is_writable": true,
				"is_readable": true,
				"path": self.pathRelative + "/"
			])
		}
		else {
			self.loadFile()
		}
	}

	func loadFile() {
		let request = [
			"mx_action": "files/file/get",
			"source": self.source as NSNumber,
			"file": self.pathRelative as NSString,
		]

		Utils().showSpinner(self.view)
		self.Request(request, {
			(data: NSDictionary!) in
			Utils().hideSpinner(self.view, animated: false)
			if let file = data["data"] as? NSDictionary {
				self.setForm(file)
			}
		}, {
			(data: NSDictionary!) in
			Utils().hideSpinner(self.view, animated: false)
			Utils().alert("", message: data["message"] as String, view: self, {
				_ in
				self.performSegueWithIdentifier("ExitView", sender: nil)
			})
		})
	}

	func setForm(data: NSDictionary) {
		self.file = data
		let form: FormDescriptor = FormDescriptor()

		var section: FormSectionDescriptor = FormSectionDescriptor()

		var row = FormRowDescriptor.init(tag: "name", rowType: FormRowType.Name, title: Utils().lexicon("file_name")) as FormRowDescriptor
		var params = NSMutableDictionary.init(dictionary: self.defaultParams)
		params["textField.font"] = UIFont.systemFontOfSize(self.defaultTextFontSize)
		row.configuration[FormRowDescriptor.Configuration.CellConfiguration] = params
		row.configuration[FormRowDescriptor.Configuration.Required] = true
		if data["name"] != nil {
			row.value = data["name"] as String
		}
		section.addRow(row)

		for (key, value) in enumerate(["path", "size", "last_accessed", "last_modified"]) {
			if data[value] != nil {
				var row = FormRowDescriptor.init(tag: value, rowType: FormRowType.Name, title: Utils().lexicon("file_" + value)) as FormRowDescriptor
				var params = NSMutableDictionary.init(dictionary: self.defaultParams)
				params["textField.font"] = UIFont.systemFontOfSize(self.defaultTextFontSize)
				params["textField.enabled"] = false
				params["textField.textColor"] = Colors().disabledText()
				if value == "size" {
					var size = data["size"] as Int
					var k = "b"
					if size > 1000000 {
						size = size / 1000000
						k = "Mb"
					}
					else if size > 1000 {
						size = size / 1000
						k = "Kb"
					}
					//row.value = "\(size) \(k)"
					params["textField.text"] = "\(size) \(k)"
				}
				else {
					//row.value = data[value] as String
					params["textField.text"] = data[value] as String
				}
				row.configuration[FormRowDescriptor.Configuration.CellConfiguration] = params
				row.configuration[FormRowDescriptor.Configuration.Required] = false
				section.addRow(row)
			}
		}

		form.sections.append(section)

		let lastHeight: CGFloat = 100
		if data["content"] != nil {
			let decodedData = NSData.init(base64EncodedString: data["content"] as String, options: nil)
			let is_image = data["image"] as Bool
			let is_writable = data["is_writable"] as Bool
			if is_image {
				if let decodedImage = UIImage.init(data: decodedData!) {
					var row = FormRowDescriptor.init(tag: "content", rowType: FormRowType.Image, title: "", height: lastHeight) as FormRowDescriptor
					row.configuration[FormRowDescriptor.Configuration.CellConfiguration] = ["imageField.image": decodedImage]
					row.configuration[FormRowDescriptor.Configuration.Required] = false

					var section: FormSectionDescriptor = FormSectionDescriptor()
					section.headerTitle = Utils().lexicon("file_content")
					section.addRow(row)
					form.sections.append(section)
				}
			}
			else if is_writable {
				if let decodedString = NSString.init(data: decodedData!, encoding: NSUTF8StringEncoding) {
					var type: FormRowType = decodedString.length > 30000
						? FormRowType.MultilineText
						: FormRowType.Code
					var row = FormRowDescriptor.init(tag: "content", rowType: type, title: "", height: lastHeight) as FormRowDescriptor
					var params = NSMutableDictionary.init(dictionary: self.defaultParams)
					params["textField.font"] = UIFont.init(name: "Courier New", size: self.defaultTextFontSize) as UIFont!
					row.configuration[FormRowDescriptor.Configuration.CellConfiguration] = params
					row.configuration[FormRowDescriptor.Configuration.Required] = false
					row.value = decodedString

					var section: FormSectionDescriptor = FormSectionDescriptor()
					section.headerTitle = Utils().lexicon("file_content")
					section.addRow(row)
					form.sections.append(section)
				}
			}
		}

		self.form = form
		self.tableView.reloadData()
		self.adjustLastRowHeight()
	}

	override func submitForm(sender: UIBarButtonItem!) {
		if let required = self.form.validateForm() {
			var message = Utils().lexicon("field_required", placeholders: ["field": required.title])
			Utils().alert("", message: message, view: self, closure: nil)
		}
		else {
			self.view.endEditing(true)
			//Utils().alert("Form data", message: self.form.formValues().description, view: self, closure: nil)
			var values = self.form.formValues()
			var request: [String:AnyObject] = [
					"mx_action": "files/file/" + self.action,
					"source": self.source as NSNumber,
					"path": self.pathRelative as NSString,
					"name": values["name"] as NSString
			]
			if values["content"] != nil {
				var content = ""
				if let plainData = (values["content"] as NSString).dataUsingEncoding(NSUTF8StringEncoding) {
					content = plainData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.init(0))
				}
				request["content"] = content
			}

			Utils().showSpinner(self.view)
			self.Request(request, {
				(data: NSDictionary!) in
				Utils().hideSpinner(self.view)

				self.title = values["name"] as? String
				if let response = data["data"] as? NSDictionary {
					self.pathRelative = response["pathRelative"] as String
					if self.action == "create" {
						self.action = "update"
					}
					self.setForm(response)
					NSNotificationCenter.defaultCenter().postNotificationName("FileUpdated", object: response)
				}
			}, {
				(data: NSDictionary!) in
				Utils().hideSpinner(self.view)
				Utils().alert("", message: data["message"] as String, view: self)
			})
		}
	}

	/*
	func textViewShouldBeginEditing(textView: UITextView) -> Bool {
		if textView == self.fileContent {
			self.navigationController?.setNavigationBarHidden(true, animated: true)
		}
		return true
	}

	func textViewShouldEndEditing(textView: UITextView) -> Bool {
		if textView == self.fileContent {
			self.navigationController?.setNavigationBarHidden(false, animated: true)
		}
		return true
	}
	*/

}
