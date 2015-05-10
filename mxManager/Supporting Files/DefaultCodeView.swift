//
//  DefaultCodeView.swift
//  mxManager
//
//  Created by Василий Наумкин on 13.03.15.
//  Copyright (c) 2015 bezumkin. All rights reserved.
//

import UIKit

class DefaultCodeView: JLTextView {

	override init(language: JLLanguageType, theme: JLColorTheme) {
		super.init(language: language, theme: theme)
		self.addBorder()
	}
/*
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.addBorder()
	}

	override init(frame: CGRect, textContainer: NSTextContainer?) {
		super.init(frame: frame, textContainer: textContainer)
		self.addBorder()
	}
*/
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