//
//  ResourceParentSelector.swift
//  mxManager
//
//  Created by Василий Наумкин on 04.04.15.
//  Copyright (c) 2015 bezumkin. All rights reserved.
//

import UIKit

class ResourceParentSelector: FormRemoteSelectorController {

	override func viewDidLoad() {
		self.invokeEvent = "LoadResourcesCombo"
		self.invokeMoreEvent = "LoadMoreResourcesCombo"
		self.searchEnabled = true
		super.viewDidLoad()
	}

	override func loadRows(spinner: Bool = true) {
		self.request = [
				"mx_action": "resources/getcombo",
				"id": formCell.rowDescriptor.configuration["id"] as! Int,
				"query": self.searchQuery,
				"start": 0
		]
		super.loadRows(spinner: spinner)
	}

	override func loadMore() {
		self.request = [
				"mx_action": "resources/getcombo",
				"id": formCell.rowDescriptor.configuration["id"] as! Int,
				"query": self.searchQuery,
				"start": self.loaded
		]
		super.loadMore()
	}

	override func onLoadRows(notification: NSNotification) {
		var ids = NSMutableArray()
		var titles = NSMutableDictionary()

		for value in self.rows as NSArray {
			var id = value["id"] as! Int
			ids.addObject(id)
			titles[id] = value["pagetitle"] as! String
		}

		formCell.rowDescriptor.configuration[FormRowDescriptor.Configuration.Options] = ids
		formCell.rowDescriptor.configuration[FormRowDescriptor.Configuration.TitleFormatterClosure] = {
			(value: AnyObject!) in
			if var id = value as? Int {
				if let title = titles[id] as? String {
					return title
				}
			}
			return nil
		} as TitleFormatterClosure
	}

	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = ResourceCell.init(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "cell") as ResourceCell

		cell.data = self.rows[indexPath.row] as! NSDictionary
		cell.template(idx: indexPath.row)

		let optionValue = cell.data["id"] as! Int
		if let selectedOption = formCell.rowDescriptor.value {
			if optionValue == selectedOption {
				cell.accessoryType = .Checkmark
			}
			else {
				cell.accessoryType = .None
			}
		}

		return cell
	}

}
