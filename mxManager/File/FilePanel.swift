//
//  FilePanel.swift
//  mxManager
//
//  Created by Василий Наумкин on 26.02.15.
//  Copyright (c) 2015 bezumkin. All rights reserved.
//

import UIKit

class FilePanel: DefaultPanel {

	@IBOutlet var fileName: UITextField!
	@IBOutlet var filePath: UITextField!
	@IBOutlet var fileSize: UITextField!
	@IBOutlet var fileLastAccessed: UITextField!
	@IBOutlet var fileLastModified: UITextField!
	@IBOutlet var fileContent: UITextView!
	@IBOutlet var fileImage: UIImageView!
	@IBOutlet var fileContentToolbar: UIToolbar!
	var file = [:]
	var source = 0
	var path = ""
	var pathRelative = ""
	var action = "update"

	override func viewDidLoad() {
		super.viewDidLoad()

		self.fileContent.inputAccessoryView = self.fileContentToolbar
		if self.action == "create" {
			self.setForm([
				"image": false,
				"content": "",
				"is_writable": true,
				"is_readable": true,
				"path": self.pathRelative + "/"
			])
			self.scrollView.hidden = false
			self.fileName.becomeFirstResponder()
		}
		else {
			self.scrollView.hidden = true
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
			Utils().hideSpinner(self.view)
			self.scrollView.hidden = false
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

	@IBAction func saveFile() {
		if !self.checkForm() {
			return
		}
		self.view.endEditing(true)

		var request: [String:AnyObject] = [:]
		if self.fileContent.hidden != true {
			var content = ""
			if let plainData = (self.fileContent.text as NSString).dataUsingEncoding(NSUTF8StringEncoding) {
				content = plainData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.init(0))
			}
			request = [
				"mx_action": "files/file/" + self.action,
				"source": self.source as NSNumber,
				"path": self.pathRelative as NSString,
				"name": self.fileName.text as NSString,
				"content": content as NSString
			]
		}
		else {
			request = [
				"mx_action": "files/file/" + self.action,
				"source": self.source as NSNumber,
				"path": self.pathRelative as NSString,
				"name": self.fileName.text as NSString,
			]
		}

		Utils().showSpinner(self.view)
		self.Request(request, {
			(data: NSDictionary!) in
			Utils().hideSpinner(self.view)

			self.title = self.fileName.text
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

	func setForm(data: NSDictionary) {
		self.file = data
		self.fileImage.hidden = true
		self.fileContent.hidden = true

		if data["content"] != nil {
			let decodedData = NSData.init(base64EncodedString: data["content"] as String, options: nil)

			let is_image = data["image"] as Bool
			let is_writable = data["is_writable"] as Bool
			if is_image {
				if let decodedImage = UIImage.init(data: decodedData!) {
					self.fileImage.image = decodedImage
					self.fileImage.hidden = false
				}
			}
			else if is_writable {
				if let decodedString = NSString.init(data: decodedData!, encoding: NSUTF8StringEncoding) {
					self.fileContent.text = decodedString
					self.fileContent.hidden = false
				}
			}
		}

		if data["name"] != nil {
			self.fileName.text = data["name"] as String
		}
		if data["path"] != nil {
			self.filePath.text = data["path"] as String
		}
		if data["size"] != nil {
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
			self.fileSize.text = "\(size) \(k)"
		}
		if data["last_accessed"] != nil {
			self.fileLastAccessed.text = data["last_accessed"] as String
		}
		if data["last_modified"] != nil {
			self.fileLastModified.text = data["last_modified"] as String
		}
	}

	func checkForm() -> Bool {
		var hasError = false

		if self.fileName.text == "" {
			hasError = true
			self.fileName.markError(true)
		}
		else {
			self.fileName.markError(false)
		}

		return hasError == false
	}

	@IBAction func fileContentDone() {
		self.fileContent.resignFirstResponder()
	}

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

}
