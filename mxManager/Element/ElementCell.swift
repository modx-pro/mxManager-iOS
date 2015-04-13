//
//  ElementCell.swift
//  mxManager
//
//  Created by Василий Наумкин on 06.02.15.
//  Copyright (c) 2015 bezumkin. All rights reserved.
//

import UIKit

class ElementCell: DefaultCell {

	override func template(idx: Int = 0) {
		super.template(idx: idx)

		let type = self.data["type"] as! String
		self.textLabel?.text = self.data["name"] as! String?
		if self.data["id"] == nil {
			self.detailTextLabel?.text = ""
			self.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
			self.imageView?.image = self._getIcon(type)
		}
		else if type == "category" {
			var count = 0
			if self.data["elements"] != nil {
				count += self.data["elements"] as! Int
			}
			if self.data["categories"] != nil {
				count += self.data["categories"] as! Int
			}
			if count == 0 {
				self.imageView?.alpha = 0.5
				self.textLabel?.alpha = 0.5
			}
			self.detailTextLabel?.text = ""
			self.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
			self.imageView?.image = self._getIcon(type)
		}
		else {
			self.detailTextLabel?.text = self.data["description"] as! String?
			self.accessoryType = UITableViewCellAccessoryType.None
			self.imageView?.image = self._getIcon(type)
			if self.data["disabled"] != nil && self.data["disabled"] as! Bool {
				self.textLabel?.font = UIFont.italicSystemFontOfSize(self.textLabel!.font!.pointSize)
				self.imageView?.alpha = 0.5
				self.textLabel?.alpha = 0.5
			}
		}
	}


	func _getIcon(section: String) -> UIImage {
		var icon: UIImage

		switch section {
			case "template":
				icon = Utils().getIcon("columns")
				break;
			case "tv":
				icon = Utils().getIcon("list-alt")
				break;
			case "chunk":
				icon = Utils().getIcon("th-large")
				break;
			case "snippet":
				icon = Utils().getIcon("file-code")
				break;
			case "plugin":
				icon = Utils().getIcon("cogs")
				break;
			case "category":
				icon = Utils().getIcon("folder")
				break;
			default:
				icon = Utils().getIcon("file-o")
				break;
			}

		return icon
	}

}
