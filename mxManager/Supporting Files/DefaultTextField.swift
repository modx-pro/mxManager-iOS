//
//  DefaultTextField.swift
//  mxManager
//
//  Created by Василий Наумкин on 19.12.14.
//  Copyright (c) 2014 bezumkin. All rights reserved.
//

import UIKit

class DefaultTextField: UITextField {

	override func awakeFromNib() {
		super.awakeFromNib()

		self.layer.cornerRadius = 5.0;
		//self.layer.masksToBounds = true;
		//self.layer.borderColor = UIColor.init(red:85/255, green:85/255, blue:85/255, alpha:1)
		//self.layer.borderWidth = 1.0;
	}

}

extension UITextField {

	func markError(marked: Bool) {
		if marked {
			self.layer.cornerRadius = 5.0;
			self.layer.masksToBounds = true;
			self.layer.borderColor = UIColor.redColor().CGColor
			self.layer.borderWidth = 1.0;
		}
		else {
			self.layer.borderColor = UIColor.clearColor().CGColor
		}
	}

}