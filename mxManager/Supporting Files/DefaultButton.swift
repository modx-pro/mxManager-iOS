//
//  DefaultButton.swift
//  mxManager
//
//  Created by Василий Наумкин on 26.01.15.
//  Copyright (c) 2015 bezumkin. All rights reserved.
//

import UIKit

class DefaultButton: UIButton {

	override func awakeFromNib() {
		super.awakeFromNib()

		self.layer.cornerRadius = 5.0
		self.layer.masksToBounds = true
		self.layer.borderColor = Colors.borderColor().CGColor
		self.layer.borderWidth = 1
		self.backgroundColor = UIColor.whiteColor()
	}

}

class BlueButton: DefaultButton {

	required init(coder aDecoder: NSCoder) {
		super.init(coder:aDecoder)
		self.setTitleColor(Colors.defaultText(), forState: UIControlState.Normal)
		self.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Highlighted)
	}

	override var highlighted: Bool {
		get {
			return super.highlighted
		}
		set {
			super.highlighted = newValue
			if newValue {
				self.backgroundColor = Colors.blue()
			}
			else {
				self.backgroundColor = UIColor.whiteColor()
			}
		}
	}

}

class RedButton: DefaultButton {

	required init(coder aDecoder: NSCoder) {
		super.init(coder:aDecoder)
		self.setTitleColor(Colors.red(), forState: UIControlState.Normal)
		self.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Highlighted)
	}

	override var highlighted: Bool {
		get {
			return super.highlighted
		}
		set {
			super.highlighted = newValue
			if newValue {
				self.backgroundColor = Colors.red()
			}
			else {
				self.backgroundColor = UIColor.whiteColor()
			}
		}
	}

}

class GreenButton: DefaultButton {

	required init(coder aDecoder: NSCoder) {
		super.init(coder:aDecoder)
		self.setTitleColor(Colors.green(), forState: UIControlState.Normal)
		self.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Highlighted)
	}

	override var highlighted: Bool {
		get {
			return super.highlighted
		}
		set {
			super.highlighted = newValue
			if newValue {
				self.backgroundColor = Colors.green()
			}
			else {
				self.backgroundColor = UIColor.whiteColor()
			}
		}
	}

}