//
//  DefaultTextField.swift
//  mxManager
//
//  Created by Василий Наумкин on 19.12.14.
//  Copyright (c) 2014 bezumkin. All rights reserved.
//

import UIKit

@IBDesignable
class DefaultTextField: UITextField {

	@IBInspectable var inset: CGFloat = 5

	/*
	override init() {
		super.init()
		self.addBorder()
	}
	*/

	override init(frame: CGRect) {
		super.init(frame: frame)
		self.addBorder()
	}

	required init(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		self.addBorder()
	}

	override func textRectForBounds(bounds: CGRect) -> CGRect {
		return CGRectInset(bounds, inset, inset)
	}

	override func editingRectForBounds(bounds: CGRect) -> CGRect {
		return textRectForBounds(bounds)
	}

	func addBorder() {
		self.layer.cornerRadius = 5.0
		self.layer.masksToBounds = true
		self.layer.borderColor = Colors.borderColor().CGColor
		self.layer.borderWidth = 0.5
	}

	override func deleteBackward() {
		super.deleteBackward()
		delegate?.textFieldShouldEndEditing?(self)
	}

}

extension UITextField {

	func markError(marked: Bool) {
		if marked {
			self.layer.borderColor = Colors.red().CGColor
		}
		else {
			self.layer.borderColor = Colors.borderColor().CGColor
		}
	}

}