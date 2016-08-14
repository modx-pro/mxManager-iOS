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

	var btnAdd: UIBarButtonItem!
	var context = ""
	var parent = 0
	var permissions = [:]
	var classes = []

	required init(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		self.invokeEvent = "LoadResources"
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		let icon = UIImage.init(named: "icon-plus")
		self.btnAdd = UIBarButtonItem.init(image: icon, style: UIBarButtonItemStyle.Plain, target: self, action: #selector(ResourcesList.showAddMenuHere(_:)))
		self.btnAdd.enabled = false
		self.navigationItem.setRightBarButtonItem(self.btnAdd, animated: false)

		NSNotificationCenter.defaultCenter().removeObserver(self, name:"ResourceUpdated", object: nil)
	}

	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		self.navigationItem.backBarButtonItem = UIBarButtonItem.init(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)

		if segue.identifier == "getResources" {
			let controller = segue.destinationViewController as! ResourcesList
			controller.data = self.data
			let cell = sender as! ResourceCell
			let type = cell.data["type"] as! String
			if type == "context" {
				controller.context = cell.data["key"] as! String
				controller.parent = 0
				if cell.data["name"] != nil {
					controller.title = cell.data["name"] as? String
				}
				else {
					controller.title = cell.data["key"] as? String
				}
			}
			else {
				controller.context = cell.data["context_key"] as! String
				controller.parent = cell.data["id"] as! Int
				controller.title = cell.data["pagetitle"] as? String
			}
			if let permissions = cell.data["permissions"] as? NSDictionary {
				controller.permissions = permissions
			}
			if let classes = cell.data["classes"] as? NSArray {
				controller.classes = classes
			}
		}
		else if segue.identifier == "showResource" {
			let controller = segue.destinationViewController as! ResourceTabPanel
			controller.data = self.data
			let cell = sender as! ResourceCell
			controller.title = cell.data["pagetitle"] as? String
			controller.id = cell.data["id"] as! Int
			controller.class_key = cell.data["class_key"] as! String
			controller.context = cell.data["context_key"] as! String
			controller.parent = cell.data["parent"] as! Int
			controller.action = controller.id == 0
				? "create"
				: "update"
			NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(refreshRows), name: "ResourceUpdated", object: nil)
		}
	}

	override func loadRows(spinner: Bool = true) {
		self.request = [
				"mx_action": "resources/getlist",
				"context": self.context,
				"parent": self.parent,
				"start": 0,
				"query": self.searchQuery
		]
		super.loadRows(spinner)
	}

	override func loadMore() {
		self.request = [
				"mx_action": "resources/getlist",
				"context": self.context,
				"parent": self.parent,
				"start": self.loaded,
				"query": self.searchQuery
		]
		super.loadMore()
	}

	override func onLoadRows(notification: NSNotification) {
		let data = notification.object as! NSDictionary

		if self.context == "" && data["context_key"] != nil {
			self.context = data["context_key"] as! String
		}
		// Сайты с одним контекстом, когда возвращается список ресурсов
		if data["permissions"] != nil {
			if let permissions = data["permissions"] as? NSDictionary {
				self.permissions = permissions
			}
			if let classes = data["classes"] as? NSArray {
				self.classes = classes
			}
		}
		if self.context != "" && self.tableHeaderView as? UISearchBar == nil {
			self.addSearchBar()
			self.tableView.tableHeaderView = self.tableHeaderView
		}

		self.btnAdd.enabled = self.canAdd(self.classes)
	}

	func canAdd(classes: NSArray) -> Bool {
		return classes.count > 0
	}

	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		//let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as ResourceCell
		let cell = ResourceCell.init(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "cell") as ResourceCell

		cell.data = self.rows[indexPath.row] as! NSDictionary
		cell.template(indexPath.row)

		return cell
	}

	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		let cell = self.tableView(tableView, cellForRowAtIndexPath: indexPath) as! ResourceCell

		if cell.accessoryType == UITableViewCellAccessoryType.DisclosureIndicator {
			self.performSegueWithIdentifier("getResources", sender: cell)
		}
		else {
			self.performSegueWithIdentifier("showResource", sender: cell)
		}
	}

	func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
		let item = self.rows[indexPath.row] as! NSDictionary
		let type = item["type"] as! String
		return type == "context"
			? UITableViewCellEditingStyle.None
			: UITableViewCellEditingStyle.Delete
	}

	func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
		let item = self.rows[indexPath.row] as! NSDictionary
		let id = item["id"] as! Int
		let type = item["type"] as! String
		let permissions = (item["permissions"] as? NSDictionary) != nil
			? item["permissions"] as! NSDictionary
			: [:]
		let classes = (item["classes"] as? NSArray) != nil
			? item["classes"] as! NSArray
			: []
		let buttons = [] as NSMutableArray

		if let deleted = item["deleted"] as? Bool {
			if (!deleted && permissions["undelete"] as! Bool) || (deleted && permissions["delete"] as! Bool) {
				let btn: UITableViewRowAction = UITableViewRowAction.init(style: UITableViewRowActionStyle.Default, title: "      ") {
					(action, indexPath) -> Void in
					tableView.editing = false
					if !deleted {
						Utils.confirm(
							item["pagetitle"] as! String,
							message: "resource_delete_confirm",
							view: self,
							closure: {
								_ in
								self.remoteAction(id, action: "delete", indexPath: indexPath)
							}
						)
					}
					else {
						self.remoteAction(id, action: "undelete", indexPath: indexPath)
					}
				}
				btn.backgroundColor = UIColor(patternImage: UIImage(named: deleted ? "btn-restore" : "btn-delete")!)
				buttons.addObject(btn)
			}
		}

		if let published = item["published"] as? Bool {
			if (published && permissions["unpublish"] as! Bool) || (!published && permissions["publish"] as! Bool) {
				let btn: UITableViewRowAction = UITableViewRowAction.init(style: UITableViewRowActionStyle.Default, title: "      ") {
					(action, indexPath) -> Void in
					tableView.editing = false
					if published {
						Utils.confirm(
							item["pagetitle"] as! String,
							message: "resource_unpublish_confirm",
							view: self,
							closure: {
								_ in
								self.remoteAction(id, action: "unpublish", indexPath: indexPath)
							}
						)
					}
					else {
						self.remoteAction(id, action: "publish", indexPath: indexPath)
					}
				}
				btn.backgroundColor = UIColor(patternImage: UIImage(named: published ? "btn-off" : "btn-on")!)
				buttons.addObject(btn)
			}
		}

		if self.canAdd(classes) {
			let btn: UITableViewRowAction = UITableViewRowAction.init(style: UITableViewRowActionStyle.Default, title: "      ") {
				(action, indexPath) -> Void in
				tableView.editing = false
				if let cell = self.tableView.cellForRowAtIndexPath(indexPath) {
					self.showAddMenu(item, sender: cell)
				}
			}
			btn.backgroundColor = UIColor(patternImage: UIImage(named: "btn-add")!)
			buttons.addObject(btn)
		}

		if type == "folder" && (permissions["view"] as! Bool || permissions["edit"] as! Bool) {
			let btn: UITableViewRowAction = UITableViewRowAction.init(style: UITableViewRowActionStyle.Default, title: "      ") {
				(action, indexPath) -> Void in
				tableView.editing = false
				if let cell = self.tableView.cellForRowAtIndexPath(indexPath) {
					self.performSegueWithIdentifier("showResource", sender: cell)
				}
			}
			btn.backgroundColor = UIColor(patternImage: UIImage(named: "btn-edit")!)
			buttons.addObject(btn)
		}

		return buttons as [AnyObject]
	}

	func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
	}

	func remoteAction(id: Int, action: String, indexPath: NSIndexPath) {
		let parameters = [
				"mx_action": "resources/" + action,
				"id": id as NSNumber,
		]
		Utils.showSpinner(self.view)
		self.Request(parameters, success: {
			(data: NSDictionary!) in
			Utils.hideSpinner(self.view)
			self.updateRow(data, indexPath: indexPath)
		}, failure: {
			(data: NSDictionary!) in
			Utils.hideSpinner(self.view)
			Utils.alert("", message: data["message"] as! String, view: self)
		})
	}

	func updateRow(data: NSDictionary, indexPath: NSIndexPath) {
		if let row = data["data"] as? NSDictionary {
			let rows = NSMutableArray()
			rows.addObjectsFromArray(self.rows as [AnyObject])
			rows[indexPath.row] = row
			self.rows = rows

			self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
		}
	}

	// Создание ресурсов

	func showAddMenuHere(sender: UIBarButtonItem!) {
		let item = [
				"id": self.parent,
				"context_key": self.context,
				"permissions": self.permissions,
				"classes": self.classes,
		]
		self.showAddMenu(item, sender: sender)
	}

	func showAddMenu(item: NSDictionary, sender: AnyObject? = nil) {
		let sheet: UIAlertController = UIAlertController.init(
			title: nil,
			message: Utils.lexicon("resource_create") as String,
			preferredStyle: UIAlertControllerStyle.ActionSheet
		)

		if let popoverController = sheet.popoverPresentationController {
			if let btn = sender as? UIBarButtonItem {
				popoverController.barButtonItem = btn
			}
			else if let cell = sender as? UITableViewCell {
				popoverController.sourceView = cell.contentView
				popoverController.sourceRect = cell.contentView.bounds
			}
		}

		if let classes = item["classes"] as? [String] {
			for class_key in classes {
				let title = Utils.lexicon(class_key) as String
				sheet.addAction(UIAlertAction.init(
					title: title,
					style: UIAlertActionStyle.Default,
					handler: {
						(alert: UIAlertAction!) in
						let cell = ResourceCell.init() as ResourceCell
						cell.data = [
								"pagetitle": title,
								"type": "resource",
								"id": 0,
								"parent": item["id"] as! Int,
								"context_key": item["context_key"] as! String,
								"permissions": item["permissions"] as! NSDictionary,
								"class_key": class_key,
						]
						self.performSegueWithIdentifier("showResource", sender: cell)
					}
				))
			}
		}

		sheet.addAction(UIAlertAction.init(
			title: Utils.lexicon("cancel") as String,
			style: UIAlertActionStyle.Cancel,
			handler: nil
		))

		self.presentViewController(sheet, animated: true, completion: nil)
		sheet.view.tintColor = Colors.defaultText()
	}

}