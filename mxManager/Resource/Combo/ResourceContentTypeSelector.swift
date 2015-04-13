//
//  ResourceContentTypeSelector.swift
//  mxManager
//
//  Created by Василий Наумкин on 08.04.15.
//  Copyright (c) 2015 bezumkin. All rights reserved.
//

import UIKit

class ResourceContentTypeSelector: FormRemoteSelectorController {

	override func viewDidLoad() {
		self.invokeEvent = "LoadContentTypesCombo"
		self.invokeMoreEvent = "LoadMoreContentTypesCombo"
		super.viewDidLoad()
	}

	override func loadRows(spinner: Bool = true) {
		self.request = [
				"mx_action": "resources/gettypes",
				"start": 0
		]
		super.loadRows(spinner: spinner)
	}

	override func loadMore() {
		self.request = [
				"mx_action": "resources/gettypes",
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
			titles[id] = value["name"] as! String
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
		let cell = DefaultCell.init(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "cell") as DefaultCell

		cell.data = self.rows[indexPath.row] as! NSDictionary
		cell.textLabel?.text = cell.data["name"] as? String
		cell.detailTextLabel?.text = cell.data["description"] as? String
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
