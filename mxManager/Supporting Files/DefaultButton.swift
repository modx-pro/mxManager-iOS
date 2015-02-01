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

		self.layer.cornerRadius = 5.0;
		self.layer.masksToBounds = true;
		self.layer.borderColor = Colors().borderColor().CGColor
		self.layer.borderWidth = 1;
	}

	override var highlighted: Bool {
		get {
			return super.highlighted
		}
		set {
			super.highlighted = newValue

			if newValue {
				let color = self.tag != 0
						? Colors().red()
						: Colors().blue()
				self.backgroundColor = color
			}
			else {
				self.backgroundColor = UIColor.whiteColor()
			}
		}
	}

}
