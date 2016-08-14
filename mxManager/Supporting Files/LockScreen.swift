//
//  LockScreen.swift
//  mxManager
//
//  Created by Василий Наумкин on 08.05.15.
//  Copyright (c) 2015 bezumkin. All rights reserved.
//

import UIKit

class LockScreen: UIViewController, UITextFieldDelegate {

	@IBOutlet var label: UILabel!
	@IBOutlet var reset: UIButton!
	@IBOutlet var i1: UITextField!
	@IBOutlet var i2: UITextField!
	@IBOutlet var i3: UITextField!
	@IBOutlet var i4: UITextField!

	var action = ""
	var tmp_pin = ""

	override func shouldAutorotate() -> Bool {
		return false
	}

	override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
		return UIInterfaceOrientationMask.Portrait
	}

	@IBAction func unwindFromViewController(sender: UIStoryboardSegue) {
	}

	override func viewWillAppear(animated: Bool) {
		self.navigationController?.setNavigationBarHidden(true, animated: true)
		super.viewWillAppear(animated)

		self.setAction()
		self.i1.becomeFirstResponder()
	}

	override func viewWillDisappear(animated: Bool) {
		self.navigationController?.setNavigationBarHidden(false, animated: true)
		super.viewWillDisappear(animated)

		self.resetForm(false)
		self.view.endEditing(true)
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		for field:UITextField in [i1, i2, i3, i4] {
			field.addTarget(self, action: #selector(LockScreen.textFieldDidChange(_:)), forControlEvents: UIControlEvents.EditingChanged)
		}

		self.reset.setTitle(Utils.lexicon("reset"), forState: UIControlState.Normal)
	}

	func setAction() {
		let pin = Utils.getPIN()
		if pin == nil {
			self.action = "create"
			self.label.text = Utils.lexicon("pin_create")
			self.reset.hidden = true
		}
		else {
			self.action = "enter"
			self.label.text = Utils.lexicon("pin_enter")
			self.reset.hidden = false
		}
	}

	func getPIN() -> String {
		var pin = ""
		for field:UITextField in [i1, i2, i3, i4] {
			pin += field.text!
		}
		return pin
	}

	func submitForm() {
		let pin = self.getPIN()
		if self.action == "create" {
			self.tmp_pin = pin
			self.action = "retry"
			self.label.text = Utils.lexicon("pin_retry")
			self.resetForm()
		}
		else if self.action == "retry" {
			if pin == self.tmp_pin {
				Utils.setPIN(pin)
				self.performSegueWithIdentifier("ShowSites", sender: self)
			}
			else {
				Utils.alert("", message: "pin_err_match", view:self) {
					_ in
					self.setAction()
					self.resetForm()
				}
			}
		}
		else if self.action == "reset" {
			let current = Utils.getPIN()
			if current == nil || pin == Utils.getPIN() {
				Utils.removePIN()
				self.setAction()
				self.resetForm()
			}
			else {
				Utils.alert("", message: "pin_err_wrong", view:self) {
					_ in
					self.setAction()
					self.resetForm()
				}
			}
		}
		else {
			if let current = Utils.getPIN() {
				if current == pin {
					self.performSegueWithIdentifier("ShowSites", sender: self)
				}
				else {
					Utils.alert("", message: "pin_err_wrong", view:self) {
						_ in
						self.resetForm()
					}
				}
			}
		}
	}

	func resetForm(showKeyboard: Bool = true) {
		for field:UITextField in [i1, i2, i3, i4] {
			field.text = ""
		}

		if showKeyboard {
			self.i1.becomeFirstResponder()
		}
	}

	@IBAction func resetPIN() {
		self.action = "reset"
		self.label.text = Utils.lexicon("pin_reset")
		self.reset.hidden = true
		self.resetForm()
	}

	func textFieldShouldEndEditing(textField: UITextField) -> Bool {
		if self.getPIN() == "" {
			self.view.endEditing(true)
		}
		return true
	}

	func textFieldDidChange(textField: UITextField) {
		// let tag = textField.tag
		let num = textField.text?.characters.count
		if num > 1 {
			textField.text = NSString(string: textField.text!).substringToIndex(1)
		}

		if num > 0 {
			var found = false
			for field:UITextField in [i1, i2, i3, i4] {
				if field.text?.characters.count == 0 {
					field.becomeFirstResponder()
					found = true
					break
				}
			}
			if !found {
				self.submitForm()
			}
		}/*
		else if tag > 1 {
			for field:UITextField in [i4, i3, i2, i1] {
				if field.tag < tag {
					field.becomeFirstResponder()
					break
				}
			}
		}*/
	}

}
