//
//  DefaultTextView.swift
//  mxManager
//
//  Created by Василий Наумкин on 11.03.15.
//  Copyright (c) 2015 bezumkin. All rights reserved.
//

import UIKit

class DefaultTextView: UITextView {

	/*
	override init() {
		super.init()
		self.addBorder()
	}
	*/

	/*
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.addBorder()
	}
	*/

	override init(frame: CGRect, textContainer: NSTextContainer?) {
		super.init(frame: frame, textContainer: textContainer)
		self.addBorder()
	}

	required init(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		self.addBorder()
	}

	func addBorder() {
		self.layer.cornerRadius = 5.0
		self.layer.masksToBounds = true
		self.layer.borderColor = Colors.borderColor().CGColor
		self.layer.borderWidth = 0.5
	}

}

extension UITextView {

	func markError(marked: Bool) {
		if marked {
			self.layer.borderColor = Colors.red().CGColor
		}
		else {
			self.layer.borderColor = Colors.borderColor().CGColor
		}
	}

}