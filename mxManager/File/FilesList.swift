//
//  FilesList.swift
//  mxManager
//
//  Created by Василий Наумкин on 04.02.15.
//  Copyright (c) 2015 bezumkin. All rights reserved.
//

import UIKit

class FilesList: DefaultTable {

	@IBOutlet var btnAdd: UIBarButtonItem!
	var source = 0
	var path = ""

	override func viewDidLoad() {
		super.viewDidLoad()
	}

	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		self.navigationItem.backBarButtonItem = UIBarButtonItem.init(title:"", style:UIBarButtonItemStyle.Plain, target:nil, action:nil)

		if segue.identifier? == "getFiles" {
			let cell = sender as FileCell
			var controller = segue.destinationViewController as FilesList
			controller.data = self.data
			let type = cell.data["type"] as String
			if type == "source" {
				controller.source = cell.data["id"] as Int
			}
			else if cell.data["type"] as String == "dir" {
				controller.source = cell.data["source"] as Int
				controller.path = cell.data["path"] as String
			}
			controller.title = cell.data["name"] as? String
		}
	}

	@IBAction func unwindFromViewController(sender: UIStoryboardSegue) {
	}

	override func loadRows(spinner: Bool = false) {
		self.request = [
			"mx_action": "file/getlist",
			"source": self.source,
			"path": self.path,
		]
		super.loadRows(spinner: spinner)
	}

	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = FileCell.init(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "cell") as FileCell
		let data = self.rows[indexPath.row] as NSDictionary
		cell.data = data
		cell.template(idx: indexPath.row)

		return cell
	}

	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		let cell = self.tableView(tableView, cellForRowAtIndexPath: indexPath) as FileCell

		if cell.accessoryType == UITableViewCellAccessoryType.DisclosureIndicator {
			self.performSegueWithIdentifier("getFiles", sender: cell)
		}
	}

}