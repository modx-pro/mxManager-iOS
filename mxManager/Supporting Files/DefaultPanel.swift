//
//  DefaultPanel.swift
//  mxManager
//
//  Created by Василий Наумкин on 02.03.15.
//  Copyright (c) 2015 bezumkin. All rights reserved.
//

import UIKit

class DefaultPanel: DefaultView, UITextFieldDelegate, UITextViewDelegate {

	@IBOutlet var scrollView: UIScrollView!
	@IBOutlet var btnSave: UIBarButtonItem!

	override func viewDidLoad() {
		super.viewDidLoad()

		NSNotificationCenter.defaultCenter().addObserver(self, selector: "onKeyboadShow:", name: UIKeyboardDidShowNotification, object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "onKeyboadHide", name: UIKeyboardDidHideNotification, object: nil)
	}

	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)

		NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardDidShowNotification, object: nil)
		NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardDidHideNotification, object: nil)
	}

	@IBAction func finishEdit(sender: UITextField) {
		sender.resignFirstResponder()
	}

	func onKeyboadShow(notification: NSNotification) {
		let info: NSDictionary = notification.userInfo!
		if let rectValue = info[UIKeyboardFrameBeginUserInfoKey] as? NSValue {
			let kbSize: CGRect = rectValue.CGRectValue()
			var contentInset: UIEdgeInsets = self.scrollView.contentInset;

			contentInset.bottom = kbSize.size.height;
			self.scrollView.contentInset = contentInset;
		}
	}

	func onKeyboadHide() {
		let contentInsets: UIEdgeInsets = UIEdgeInsetsZero;
		self.scrollView.contentInset = contentInsets;
		self.scrollView.scrollIndicatorInsets = contentInsets;
	}

}
