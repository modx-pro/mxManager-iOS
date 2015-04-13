//
//  PopupWindow.swift
//  ModalForm
//
//  Created by Василий Наумкин on 13.04.15.
//  Copyright (c) 2015 bezumkin. All rights reserved.
//

import UIKit

class PopupWindow: UIViewController, UITextFieldDelegate {

	@IBOutlet var wrapper: UIView!
	@IBOutlet var btnCancel: UIButton!
	@IBOutlet var btnSave: UIButton!
	@IBOutlet var textField: UITextField!
	@IBOutlet var labelField: UILabel!

	var keyboardHeight: CGFloat = 0
	var data = [:]
	var closure: ((textField: UITextField!) -> Void)?
	var tmpText = ""

	override func viewDidLoad() {
		super.viewDidLoad()

		self.labelField.text = self.data["title"] as? String
		self.textField.text = self.data["text"] as? String
		if (self.data["text"] as? String) != nil {
			self.tmpText = self.data["text"] as! String
		}

		self.btnCancel.setTitle(Utils().lexicon("cancel"), forState: UIControlState.Normal)
		var tmp = self.data["save"] != nil
			? self.data["save"] as! String
			: Utils().lexicon("save")
		self.btnSave.setTitle(tmp, forState: UIControlState.Normal)
		self.btnSave.enabled = false

		self.wrapper.layer.cornerRadius = 5.0 as CGFloat
		self.textField.becomeFirstResponder()
	}

	@IBAction func onBtnCancel() {
		self.dismissViewControllerAnimated(true, completion: nil)
	}

	@IBAction func onBtnSave() {
		if self.closure != nil {
			self.dismissViewControllerAnimated(true, completion: {
				_ in
				self.closure!(textField: self.textField)
			})
		}

	}

	override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
		self.fixTopOffset()
	}

	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)

		NSNotificationCenter.defaultCenter().addObserver(self, selector: "textFieldDidChange:", name: UITextFieldTextDidChangeNotification, object: self.textField)

		NSNotificationCenter.defaultCenter().addObserver(self, selector: "onKeyboadWillShow:", name: UIKeyboardWillShowNotification, object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "onKeyboadWillShow:", name: UIKeyboardWillChangeFrameNotification, object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "onKeyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
	}

	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)

		NSNotificationCenter.defaultCenter().removeObserver(self, name: UITextFieldTextDidChangeNotification, object: nil)

		NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
		NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillChangeFrameNotification, object: nil)
		NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
	}

	func onKeyboadWillShow(notification: NSNotification) {
		self.fixTopOffset()
		let info: NSDictionary = notification.userInfo!
		if let rectValue = info[UIKeyboardFrameBeginUserInfoKey] as? NSValue {
			let kbSize: CGRect = rectValue.CGRectValue()
			if self.keyboardHeight != kbSize.size.height {
				self.keyboardHeight = kbSize.size.height
				self.fixTopOffset()
			}
		}
	}

	func onKeyboardWillHide(notification: NSNotification) {
		self.fixTopOffset()
		if self.keyboardHeight != 0 {
			self.keyboardHeight = 0
			self.fixTopOffset()
		}
	}

	func fixTopOffset(landscape: Bool = true) {
		let height1: CGFloat = self.view.frame.height / 2
		let height2: CGFloat = height1 - self.keyboardHeight / 2
		let margin: CGFloat = height1 - height2
		for tmp in self.view.constraints() {
			if let constraint = tmp as? NSLayoutConstraint {
				if constraint.firstAttribute == NSLayoutAttribute.CenterY {
					if constraint.constant != margin {
						constraint.constant = margin
					}
				}
			}

		}
	}

	func textFieldDidChange(notification: NSNotification) {
		if notification.object != nil {
			if let textField = notification.object as? UITextField {
				self.btnSave.enabled = count(textField.text) > 0 && textField.text != self.tmpText
			}
		}
	}

}
