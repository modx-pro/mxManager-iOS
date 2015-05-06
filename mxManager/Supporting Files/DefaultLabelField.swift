//
//  DefaultLabelField.swift
//  mxManager
//
//  Created by Василий Наумкин on 15.03.15.
//  Copyright (c) 2015 bezumkin. All rights reserved.
//

import UIKit

@IBDesignable
class DefaultLabelField: UILabel {

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

	override func drawTextInRect(rect: CGRect) {
		var insets = UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
		super.drawTextInRect(UIEdgeInsetsInsetRect(rect, insets))
	}

	func addBorder() {
		self.layer.cornerRadius = 5.0;
		self.layer.masksToBounds = true;
		self.layer.borderColor = Colors.borderColor().CGColor
		self.layer.borderWidth = 0.5;
	}

}

extension UILabel {

	func markError(marked: Bool) {
		if marked {
			self.layer.borderColor = Colors.red().CGColor
		}
		else {
			self.layer.borderColor = Colors.borderColor().CGColor
		}
	}

}