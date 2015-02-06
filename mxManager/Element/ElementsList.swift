//
//  ElementsList.swift
//  mxManager
//
//  Created by Василий Наумкин on 06.02.15.
//  Copyright (c) 2015 bezumkin. All rights reserved.
//

import UIKit

class ElementsList: DefaultTable {

	var section = ""
	var category = 0

	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		self.navigationItem.backBarButtonItem = UIBarButtonItem.init(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)

		if segue.identifier? == "getElements" {
			let controller = segue.destinationViewController as ElementsList
			let cell = sender as ElementCell
			controller.data = self.data
			controller.title = cell.data["title"] as? String

			let type = cell.data["type"] as String
			if type == "section" {
				controller.section = cell.data["section"] as String
				controller.category = 0
			}
			else if type == "category" {
				controller.section = cell.data["section"] as String
				controller.category = cell.data["id"] as Int
			}
		}
	}

	override func loadRows(spinner: Bool = true) {
		self.request = [
				"mx_action": "element/getlist",
				"section": self.section,
				"category": self.category,
				"start": 0
		]
		super.loadRows(spinner: spinner)
	}

	override func loadMore() {
		self.request = [
				"mx_action": "element/getlist",
				"section": self.section,
				"category": self.category,
				"start": self.count
		]
		super.loadMore()
	}

	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = ElementCell.init(style: UITableViewCellStyle.Default, reuseIdentifier: "cell") as ElementCell

		cell.data = self.rows[indexPath.row] as NSDictionary
		cell.template(idx: indexPath.row)

		return cell
	}

	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		let cell = self.tableView(tableView, cellForRowAtIndexPath: indexPath) as ElementCell

		if cell.accessoryType == UITableViewCellAccessoryType.DisclosureIndicator {
			self.performSegueWithIdentifier("getElements", sender: cell)
		}
	}

}
