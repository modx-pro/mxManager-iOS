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

		self.textLabel?.text = self.data["title"] as String?

		let section = self.data["section"] as String
		let type = self.data["type"] as String
		if type == "section" {
			self.detailTextLabel?.text = ""
			self.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
			let section = self.data["section"] as String
			switch section {
				case "template":
					self.imageView?.image = Utils().getIcon("columns")
					break;
				case "tv":
					self.imageView?.image = Utils().getIcon("list-alt")
					break;
				case "chunk":
					self.imageView?.image = Utils().getIcon("th-large")
					break;
				case "snippet":
					self.imageView?.image = Utils().getIcon("file-code")
					break;
				case "plugin":
					self.imageView?.image = Utils().getIcon("cogs")
					break;
				case "category":
					self.imageView?.image = Utils().getIcon("folder")
					break;
				default:
					break;
			}
		}
		else if type == "category" {
			self.detailTextLabel?.text = ""
			if section == "category" && self.data["categories"] as Int == 0 {
				self.accessoryType = UITableViewCellAccessoryType.None
			}
			else {
				self.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
			}
			self.imageView?.image = Utils().getIcon("folder")
		}
		else if type == "element" {
			self.detailTextLabel?.text = self.data["description"] as String?
			self.accessoryType = UITableViewCellAccessoryType.None
			self.imageView?.image = Utils().getIcon("file-o")
		}
	}

}
