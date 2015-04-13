//
//  SitesList.swift
//  mxManager
//
//  Created by Василий Наумкин on 18.12.14.
//  Copyright (c) 2014 bezumkin. All rights reserved.
//

import UIKit

class SitesList: DefaultTable {

	@IBOutlet var btnAdd: UIBarButtonItem!

	override func viewDidLoad() {
		super.viewDidLoad()

		NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshRows", name:"SiteAdded", object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshRows", name:"SiteDeleted", object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshRows", name:"SiteUpdated", object: nil)
	}

	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		self.navigationItem.backBarButtonItem = UIBarButtonItem.init(title:"", style:UIBarButtonItemStyle.Plain, target:nil, action:nil)

		if segue.identifier == "ShowSettings" {
			var controller = segue.destinationViewController as! SiteSettings
			controller.data = sender as! NSDictionary
		}
		else if segue.identifier == "ShowSite" {
			let cell = sender as! DefaultCell
			var controller = segue.destinationViewController as! SiteMain
			controller.data = cell.data as NSDictionary
			controller.title = cell.data["site"] as? String
		}
	}

	override func loadRows(spinner: Bool = false) {
		let rows = Utils().getSites()
		if rows.count > 0 {
			self.rows = rows
			self.refreshControl.endRefreshing()
			self.tableView.reloadData()
		}
	}

	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! SiteCell
		let data = self.rows[indexPath.row] as! NSDictionary
		cell.data = data
		cell.template(idx: indexPath.row)

		return cell
	}

	func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
		let data = self.rows[indexPath.row] as! NSDictionary
		if data["key"] == nil {
			println("No key in \(data)")
			return []
		}
		let key = data["key"] as! String

		let edit: UITableViewRowAction = UITableViewRowAction.init(style: UITableViewRowActionStyle.Default, title: "      ") {
			(action, indexPath) -> Void in
			tableView.editing = false

			self.performSegueWithIdentifier("ShowSettings", sender: data)
		}
		edit.backgroundColor = UIColor(patternImage: UIImage(named:"btn-edit")!)

		let delete: UITableViewRowAction = UITableViewRowAction.init(style: UITableViewRowActionStyle.Normal, title: "      ") {
			(action, indexPath) -> Void in
			tableView.editing = false

			Utils().confirm("warning", message:"site_delete_confirm", view: self, closure: { _ in
				if Utils().removeSite(key) {}
			})
		}
		delete.backgroundColor = UIColor(patternImage: UIImage(named:"btn-delete")!)

		return [delete, edit]
	}

	func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
	}

}
