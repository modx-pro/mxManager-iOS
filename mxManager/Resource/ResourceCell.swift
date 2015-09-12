//
//  DefaultCell.swift
//  mxManager
//
//  Created by Василий Наумкин on 24.12.14.
//  Copyright (c) 2014 bezumkin. All rights reserved.
//

import UIKit

class ResourceCell: DefaultCell {

	override func template(idx: Int = 0) {
		super.template(idx)

		let type: String = self.data["type"] as! String
		if type == "context" {
			if self.data["name"] != nil {
				self.textLabel?.text = self.data["name"] as! String?
			}
			else {
				self.textLabel?.text = self.data["key"] as! String?
			}
			self.detailTextLabel?.text = self.data["description"] as! String?
			self.imageView?.image = Utils.getIcon("globe")
			self.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
		}
		else {
			if (self.data["id"] as! Int) > 0 {
				self.textLabel?.text = NSString.init(format: "%@ (%i)", self.data["pagetitle"] as! String, self.data["id"] as! Int) as String
			}
			else {
				self.textLabel?.text = self.data["pagetitle"] as! String?
			}
			self.detailTextLabel?.text = self.data["longtitle"] as! String?

			if type == "folder" {
				self.imageView?.image = Utils.getIcon("folder")
				self.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
			}
			else {
				var image: String
				switch self.data["class_key"] as! String {
				case "modSymLink":
					image = "files"
				break
				case "modWebLink":
					image = "link"
				break
				case "modStaticResource":
					image = "file-text"
				break
				default:
					image = "file"
				}
				self.imageView?.image = Utils.getIcon(image)
				self.accessoryType = UITableViewCellAccessoryType.None
			}

			//var normalColor = Colors.defaultText()
			//var disabledColor = Colors.disabledText()
			let deletedColor = Colors.red(0.3)

			if self.data["hidemenu"] as! Int == 1 || self.data["published"] as! Int == 0 {
				self.imageView?.alpha = 0.5
				self.textLabel?.alpha = 0.5
				self.detailTextLabel?.alpha = 0.5
			}

			if self.data["published"] as! Int == 0 {
				if self.textLabel?.font != nil {
					self.textLabel?.font = UIFont.italicSystemFontOfSize(self.textLabel!.font!.pointSize)
				}
				if self.detailTextLabel?.font != nil {
					self.detailTextLabel?.font = UIFont.italicSystemFontOfSize(self.detailTextLabel!.font!.pointSize)
				}
			}

			if self.data["deleted"] as! Int == 1 {
				self.textLabel?.textColor = deletedColor
				self.detailTextLabel?.textColor = deletedColor
				self.imageView?.tintColor = deletedColor

				let attributes = [NSStrikethroughStyleAttributeName: 1]
				if self.textLabel?.text != nil {
					self.textLabel?.attributedText = NSAttributedString.init(string: self.textLabel!.text!, attributes: attributes)
				}
				if self.detailTextLabel?.text != nil {
					self.detailTextLabel?.attributedText = NSAttributedString.init(string: self.detailTextLabel!.text!, attributes: attributes)
				}
			}
		}
	}

}
