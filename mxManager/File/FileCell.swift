//
//  FileCell.swift
//  mxManager
//
//  Created by Василий Наумкин on 04.02.15.
//  Copyright (c) 2015 bezumkin. All rights reserved.
//

import UIKit

class FileCell: DefaultCell {

	override func template(idx: Int = 0) {
		super.template(idx: idx)

		self.textLabel?.text = self.data["name"] as! String?
		let type: String = self.data["type"] as! String
		switch type {
			case "source":
				self.detailTextLabel?.text = self.data["description"] as! String?
				self.imageView?.image = Utils.getIcon("hdd")
				self.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
				break
			case "dir":
				self.detailTextLabel?.text = ""
				self.imageView?.image = Utils.getIcon("folder")
				self.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
				break
			case "image":
				self.detailTextLabel?.text = ""
				self.accessoryType = UITableViewCellAccessoryType.None
				self.imageView?.image = Utils.getIcon("file-image")
				break
			case "file":
				self.detailTextLabel?.text = ""
				self.accessoryType = UITableViewCellAccessoryType.None
				let ext: String = self.data["ext"] as! String
				switch ext {
					case "htaccess", "access":
						self.imageView?.image = Utils.getIcon("lock")
						break
					case "txt", "rtf", "md":
						self.imageView?.image = Utils.getIcon("file-text")
						break
					case "php", "xml", "js", "css", "less", "scss", "tpl", "html":
						self.imageView?.image = Utils.getIcon("file-code")
						break
				 	default:
						self.imageView?.image = Utils.getIcon("file-o")
				}
			default:
				break
		}

	}

}