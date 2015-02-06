//
//  ResourcesList.swift
//  mxManager
//
//  Created by Василий Наумкин on 26.12.14.
//  Copyright (c) 2014 bezumkin. All rights reserved.
//

import UIKit
import Alamofire

class ResourcesList: DefaultTable {

	var context = ""
	var parent = 0

	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		self.navigationItem.backBarButtonItem = UIBarButtonItem.init(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)

		if segue.identifier? == "getResources" {
			let controller = segue.destinationViewController as ResourcesList
			controller.data = self.data
			let cell = sender as ResourceCell
			let type = cell.data["type"] as String
			if type == "context" {
				controller.context = cell.data["key"] as String
				controller.parent = 0
				if cell.data["name"] != nil {
					controller.title = cell.data["name"] as? String
				}
				else {
					controller.title = cell.data["key"] as? String
				}
			}
			else {
				controller.context = cell.data["context_key"] as String
				controller.parent = cell.data["id"] as Int
				controller.title = cell.data["pagetitle"] as? String
			}
		}
	}

	override func loadRows(spinner: Bool = true) {
		self.request = [
			"mx_action": "resource/getlist",
			"context": self.context,
			"parent": self.parent,
			"start": 0
		]
		super.loadRows(spinner: spinner)
	}

	override func loadMore() {
		self.request = [
				"mx_action": "resource/getlist",
				"context": self.context,
				"parent": self.parent,
				"start": self.count
		]
		super.loadMore()
	}

	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		//let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as ResourceCell
		let cell = ResourceCell.init(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "cell") as ResourceCell

		cell.data = self.rows[indexPath.row] as NSDictionary
		cell.template(idx: indexPath.row)

		return cell
	}

	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		let cell = self.tableView(tableView, cellForRowAtIndexPath: indexPath) as ResourceCell

		if cell.accessoryType == UITableViewCellAccessoryType.DisclosureIndicator {
			self.performSegueWithIdentifier("getResources", sender: cell)
		}
	}

	func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
		let data = self.rows[indexPath.row] as NSDictionary
		let permissions = data["permissions"] as NSDictionary
		let id = data["id"] as Int

		var moreButton:UITableViewRowAction = UITableViewRowAction.init(style: UITableViewRowActionStyle.Default, title: "      ") {
			(action, indexPath) -> Void in
			tableView.editing = false

			var sheet: UIAlertController = UIAlertController.init(
				title: data["pagetitle"] as String?,
				message: data["longtitle"] as String?,
				preferredStyle: UIAlertControllerStyle.ActionSheet
			)
			sheet.view.tintColor = Colors().defaultText()
			/*
			if permissions["view"] as Bool {
				sheet.addAction(self.addAction(id, action:"view"))
			}
			if permissions["edit"] as Bool {
				sheet.addAction(self.addAction(id, action:"edit"))
			}
			*/
			if data["published"] as Int == 1 && permissions["unpublish"] as Bool {
				sheet.addAction(self.addAction(id, action:"unpublish", indexPath:indexPath))
			}
			else if data["published"] as Int == 0 && permissions["publish"] as Bool {
				sheet.addAction(self.addAction(id, action:"publish", indexPath:indexPath))
			}
			if data["deleted"] as Int == 1 && permissions["undelete"] as Bool {
				sheet.addAction(self.addAction(id, action:"undelete", indexPath:indexPath))
			}
			else if data["deleted"] as Int == 0 && permissions["delete"] as Bool {
				sheet.addAction(self.addAction(id, action:"delete", indexPath:indexPath))
			}

			sheet.addAction(UIAlertAction.init(
				title: Utils().lexicon("cancel"),
				style: UIAlertActionStyle.Cancel,
				handler: nil
			))
			self.presentViewController(sheet, animated: true, completion: nil)
		}
		moreButton.backgroundColor = UIColor(patternImage: UIImage(named:"btn-list")!)

		return [moreButton]
	}

	func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
	}

	func addAction(id: Int, action: String, indexPath: NSIndexPath?) -> UIAlertAction {
		return UIAlertAction.init(
			title: Utils().lexicon(action),
			style: UIAlertActionStyle.Default,
			handler: {
				(alert: UIAlertAction!) in

				let parameters = [
						"mx_action": "resource/" + action,
						"id": id as NSNumber,
				]
				Utils().showSpinner(self.view)
				self.Request(parameters, {
					data in
					if indexPath != nil {
						if let row = data["data"] as? NSDictionary {
							let rows = NSMutableArray.init() as NSMutableArray
							rows.addObjectsFromArray(self.rows)
							rows[indexPath!.row] = row
							self.rows = rows
							if self.tableView != nil {
								self.tableView!.reloadRowsAtIndexPaths([indexPath!] as NSArray, withRowAnimation: UITableViewRowAnimation.Fade)
							}
						}
					}
					Utils().hideSpinner(self.view)
				}, {
					data in
					Utils().hideSpinner(self.view)
					Utils().alert("", message: data["message"] as String, view: self)
				})
			}
		)
	}
}