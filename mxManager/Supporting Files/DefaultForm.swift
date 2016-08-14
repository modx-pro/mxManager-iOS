//
//  DefaultForm.swift
//  mxManager
//
//  Created by Василий Наумкин on 10.03.15.
//  Copyright (c) 2015 bezumkin. All rights reserved.
//

import UIKit

class DefaultForm: FormViewController, FormViewControllerDelegate {

	var data = [:]
	var name = ""
	@IBOutlet var tableHeaderView: UIView?
	@IBOutlet var tableFooterView: UIView?
	var defaultLabelFontSize: CGFloat = 14.0
	var defaultTextFontSize: CGFloat = 14.0
	var defaultParams = [
		"titleLabel.font": UIFont.systemFontOfSize(14),
		"titleLabel.color": Colors.defaultText(),
		"titleLabel.textAlignment": NSTextAlignment.Right.rawValue
	]
	var keyboardHeight: CGFloat = 0
	var isRotating: Bool = false
	var wasAdjusted = false
	var defaultView: DefaultView?

	override func viewDidLoad() {
		// Default form
		if self.form == nil {
			let form: FormDescriptor = FormDescriptor()
			form.title = self.title
			self.form = form
		}

		self.tableView.sectionHeaderHeight = 1
		self.tableView.sectionFooterHeight = 1

		super.viewDidLoad()
		self.prepareTable()
	}

	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)

		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(DefaultForm.onKeyboadWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(DefaultForm.onKeyboadWillShow(_:)), name: UIKeyboardWillChangeFrameNotification, object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(DefaultForm.onKeyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
	}

	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)

		NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
		NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillChangeFrameNotification, object: nil)
		NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
	}

	func cellForTag(tag: String) -> AnyObject! {
		for (s, section) in form.sections.enumerate() {
			for (r, row) in section.rows.enumerate() {
				if row.tag == tag {
					let indexPath = NSIndexPath.init(forRow: r, inSection: s)
					if let cell = self.tableView.cellForRowAtIndexPath(indexPath) {
						return cell
					}
				}
			}
		}
		return nil
	}

	func prepareTable() {
		self.addSaveButton()

		let backgroundColor = Colors.sectionBackground()
		self.tableView.backgroundColor = backgroundColor

		if self.tableHeaderView == nil {
			let header = UIView.init() as UIView
			header.frame = CGRectMake(0, 0, 0, 5)
			header.backgroundColor = backgroundColor
			self.tableHeaderView = header
		}
		self.tableView.tableHeaderView = self.tableHeaderView

		if self.tableFooterView == nil {
			let footer = UIView.init() as UIView
			footer.frame = CGRectMake(0, 0, 0, 5)
			footer.backgroundColor = backgroundColor
			self.tableFooterView = footer
		}
		self.tableView.tableFooterView = self.tableFooterView

		self.tableView.separatorColor = UIColor.clearColor()
	}

	func addSaveButton() {
		let icon = UIImage.init(named: "icon-check")
		let btn = UIBarButtonItem.init(image: icon, style: UIBarButtonItemStyle.Plain, target: self, action: #selector(DefaultForm.submitForm(_:)))
		self.navigationItem.setRightBarButtonItem(btn, animated: false)
	}

	func addHideKeyboardButton() {
		let icon = UIImage.init(named: "icon-keyboard-hide")
		let btn = UIBarButtonItem.init(image: icon, style: UIBarButtonItemStyle.Plain, target: self, action: #selector(DefaultForm.finishEdit(_:)))
		self.navigationItem.setRightBarButtonItem(btn, animated: false)
	}

	override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return self.form.sections[section].headerTitle != nil
			? 29
			: 0
	}

	override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		return self.form.sections[section].footerTitle != nil
			? 29
			: 0
	}

	override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let view = UIView.init() as UIView
		view.backgroundColor = Colors.sectionBackground()

		if self.form.sections[section].headerTitle != nil {
			if self.form.sections[section].headerTitle != "" {
				let height = self.tableView(tableView, heightForHeaderInSection: section)
				let width = tableView.frame.width

				let label = UILabel.init(frame: CGRectMake(8, 0, width, height)) as UILabel
				label.textColor = Colors.defaultText()
				label.text = self.form.sections[section].headerTitle
				label.font = UIFont.systemFontOfSize(self.defaultLabelFontSize)

				view.addSubview(label)
				return view
			}
		}

		return view
	}

	override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
		let view = UIView.init() as UIView
		view.backgroundColor = Colors.sectionBackground()

		if self.form.sections[section].footerTitle != nil {
			if self.form.sections[section].footerTitle != "" {
				let height = self.tableView(tableView, heightForFooterInSection: section)
				let width = tableView.frame.width

				let label = UILabel.init(frame: CGRectMake(8, 0, width, height)) as UILabel
				label.textColor = Colors.defaultText()
				label.text = self.form.sections[section].footerTitle
				label.font = UIFont.systemFontOfSize(self.defaultTextFontSize)

				view.addSubview(label)
				return view
			}
		}

		return view
	}

	/*
	override func prefersStatusBarHidden() -> Bool {
		return false
	}
	*/

	func Request(parameters: [String:AnyObject], success: ((data:NSDictionary!) -> Void)?, failure: ((data:NSDictionary!) -> Void)?) {
		self.defaultView = DefaultView()
		self.defaultView!.data = self.data
		self.defaultView!.Request(parameters, success: success, failure: failure)
	}

	func finishEdit(sender: UIBarButtonItem!) {
		self.view.endEditing(true)
	}

	func getFormValues() -> NSDictionary {
		if self.form != nil {
			return self.form.formValues()
		}
		else {
			return [:]
		}
	}

	func setFormValues(data: AnyObject) {
		let form: FormDescriptor = FormDescriptor()

		self.form = form
		// override
		//self.tableView.reloadData()
		//self.adjustLastRowHeight()

		print(data)
	}

	func submitForm(sender: UIBarButtonItem!) {
		let values = self.form.formValues()
		var message = values.description

		if let required = self.form.validateForm() {
			/*
			let tmp: AnyObject = self.cellForTag(required.tag)
			if var cell = tmp as? FormTextViewCell {
				cell.textField.markError(true)
			}
			else if var cell = tmp as? FormTextCodeCell {
				cell.textField.markError(true)
			}
			else if var cell = tmp as? FormTextFieldCell {
				cell.textField.markError(true)
			}
			*/
			message = Utils.lexicon("field_required", placeholders: ["field": required.title]) as String
			Utils.alert("", message: message, view: self, closure: nil)
		}
		else {
			self.view.endEditing(true)
			Utils.alert("Form data", message: message, view: self, closure: nil)
			print(values)
		}
	}

	func onKeyboadWillShow(notification: NSNotification) {
		let info: NSDictionary = notification.userInfo!
		if let rectValue = info[UIKeyboardFrameBeginUserInfoKey] as? NSValue {
			let kbSize: CGRect = rectValue.CGRectValue()
			//var contentInset: UIEdgeInsets = self.tableView.contentInset
			//contentInset.bottom = kbSize.size.height
			//self.tableView.contentInset = contentInset
			if self.keyboardHeight != kbSize.size.height {
				self.keyboardHeight = kbSize.size.height
				dispatch_async(dispatch_get_main_queue()) {
					self.addHideKeyboardButton()
				}
				if self.wasAdjusted {
					self.adjustLastRowHeight()
				}
			}
		}
	}

	func onKeyboardWillHide(notification: NSNotification) {
		if self.keyboardHeight != 0 {
			self.keyboardHeight = 0
			dispatch_async(dispatch_get_main_queue()) {
				self.addSaveButton()
			}
			if self.wasAdjusted {
				self.adjustLastRowHeight()
			}
		}
	}

	func adjustLastRowHeight(minHeight: CGFloat = 100, hideKeyboard: Bool = false) {
		if self.isRotating {
			return
		}
		self.wasAdjusted = true

		var screenHeight = self.view.frame.height
		if let controller = self.parentViewController as? UITabBarController {
			if !controller.tabBar.translucent && self.keyboardHeight > 0 {
				screenHeight += controller.tabBar.frame.height
			}
		}
		let tableHeight = self.tableView.contentSize.height
		let isLandscape = UIApplication.sharedApplication().statusBarOrientation.isLandscape

		if self.form.sections.count > 0 {
			let section: Int = self.form.sections.count - 1
			let lastSection = self.form.sections[section] as FormSectionDescriptor
			let row: Int = lastSection.rows.count - 1
			let lastRow = lastSection.rows[row] as FormRowDescriptor

			let indexPath = NSIndexPath.init(forRow: row, inSection: section)
			let currentHeight = self.tableView(self.tableView, heightForRowAtIndexPath: indexPath)

			var newHeight = currentHeight
			let onlyTableHeight = tableHeight - currentHeight
			if onlyTableHeight + minHeight < screenHeight && !isLandscape && self.keyboardHeight == 0 {
				newHeight = screenHeight - onlyTableHeight
			}
			else {
				newHeight = screenHeight - self.keyboardHeight - 40 //- (isLandscape ? 65 : 50)
			}
			if newHeight < minHeight {
				newHeight = minHeight
			}

			lastRow.configuration[FormRowDescriptor.Configuration.CellHeight] = newHeight
			dispatch_async(dispatch_get_main_queue()) {
				if (hideKeyboard) {
					self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.None)
				}
				else {
					self.tableView.beginUpdates()
					self.tableView.endUpdates()
				}
			}
		}
	}

	override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
		self.isRotating = true
	}

	override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
		self.isRotating = false
		if self.wasAdjusted {
			self.adjustLastRowHeight()
		}
	}

}
