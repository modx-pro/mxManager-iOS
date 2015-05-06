//
//  DefaultCell.swift
//  mxManager
//
//  Created by Василий Наумкин on 24.12.14.
//  Copyright (c) 2014 bezumkin. All rights reserved.
//

import UIKit

class DefaultCell: UITableViewCell {

	var data = [:]

	override func setSelected(selected: Bool, animated: Bool) {
		super.setSelected(false, animated: animated);
	}

	override func layoutSubviews() {
		super.layoutSubviews()

		if self.imageView?.image != nil {
			self.imageView?.image = self.imageView!.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
			self.imageView?.bounds = CGRectMake(8, 13, 24, 24)
			self.imageView?.frame = CGRectMake(8, 13, 24, 24)

			if var tmpFrame = self.textLabel?.frame {
				tmpFrame.origin.x = 40;
				self.textLabel?.frame = tmpFrame
			}

			if var tmpFrame = self.detailTextLabel?.frame {
				tmpFrame.origin.x = 40;
				self.detailTextLabel?.frame = tmpFrame
			}

			// Change default color of icons
			if self.imageView?.tintColor == Colors.systemTint() {
				self.imageView?.tintColor = Colors.defaultText()
			}
		}

		self.separatorInset = UIEdgeInsetsZero
		self.layoutMargins = UIEdgeInsetsZero
		self.preservesSuperviewLayoutMargins = false
	}

	func template(idx: Int = 0) {
		self.backgroundColor = idx % 2 == 1
				? Colors.tableAlternate()
				: UIColor.whiteColor()

		let textColor = Colors.defaultText()
		self.textLabel?.textColor = textColor
		self.detailTextLabel?.textColor = textColor
		self.imageView?.tintColor = textColor
	}

}
