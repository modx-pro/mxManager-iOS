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
	var exitBtn: UIBarButtonItem?
	var infoBtn: UIBarButtonItem?

	override func viewDidLoad() {
		super.viewDidLoad()

		NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshRows", name:"SiteAdded", object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshRows", name:"SiteDeleted", object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshRows", name:"SiteUpdated", object: nil)

		self.addLeftButtons()
	}

	func addLeftButtons() {
		self.exitBtn = UIBarButtonItem.init(image: UIImage.init(named: "icon-power-off"), style: UIBarButtonItemStyle.Plain, target: self, action: "exitView")
		self.infoBtn = UIBarButtonItem.init(image: UIImage.init(named: "icon-info"), style: UIBarButtonItemStyle.Plain, target: self, action: "showInfo")

		self.navigationItem.setLeftBarButtonItems([self.exitBtn!, self.infoBtn!], animated: false)
	}

	override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {

		//IAPManager.sharedManager.clearPurchasedItems()
		let productId = "bez.mxManager.MultipleSites"
		if identifier == "AddSite" {
			let sites = Utils.getSites()
			if sites.count == 0 {
				return true
			}
			else if !IAPManager.sharedManager.isProductPurchased(productId) {
				self.btnAdd.enabled = false
				Utils.showSpinner(self.view)
				IAPManager.sharedManager.purchaseProductWithId(productId) {
					(error) -> Void in
					Utils.hideSpinner(self.view)
					self.btnAdd.enabled = true
					if error != nil {
						if error!.code == 2 {
							return
						}
						Utils.alert(
							"error",
							message: (error!.userInfo[NSLocalizedDescriptionKey] != nil)
								? error!.userInfo[NSLocalizedDescriptionKey] as! String
								: "",
							view: self
						)
					}
					else {
						self.performSegueWithIdentifier("AddSite", sender: nil)
					}
				}
				return false
			}
		}
		return true
	}

	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		self.navigationItem.backBarButtonItem = UIBarButtonItem.init(title:"", style:UIBarButtonItemStyle.Plain, target:nil, action:nil)

		if segue.identifier == "AddSite" {
			let controller = segue.destinationViewController as! SiteSettings
			if let data = sender as? NSDictionary {
				if data["disable_cancel"] != nil {
					controller.disableCancel = true
				}
			}
		}
		else if segue.identifier == "ShowSettings" {
			let controller = segue.destinationViewController as! SiteSettings
			controller.data = sender as! NSDictionary
		}
		else if segue.identifier == "ShowSite" {
			let cell = sender as! DefaultCell
			let controller = segue.destinationViewController as! SiteMain
			controller.data = cell.data as NSDictionary
			controller.title = cell.data["site"] as? String
		}
	}

	override func loadRows(spinner: Bool = false) {
		let rows = Utils.getSites()
		self.refreshControl.endRefreshing()
		if rows.count > 0 {
			self.rows = rows
			self.tableView.reloadData()
		}
		else {
			dispatch_async(dispatch_get_main_queue()) {
				self.performSegueWithIdentifier("AddSite", sender: ["disable_cancel": true])
			}
		}
	}

	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! SiteCell
		let data = self.rows[indexPath.row] as! NSDictionary
		cell.data = data
		cell.template(indexPath.row)

		return cell
	}

	func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
		let data = self.rows[indexPath.row] as! NSDictionary
		if data["key"] == nil {
			print("No key in \(data)")
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

			Utils.confirm("warning", message:"site_delete_confirm", view: self, closure: { _ in
				if Utils.removeSite(key) {}
			})
		}
		delete.backgroundColor = UIColor(patternImage: UIImage(named:"btn-delete")!)

		return [delete, edit]
	}

	func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
	}

	func exitView() {
		self.performSegueWithIdentifier("ExitView", sender: self.exitBtn)
	}

	func showInfo() {
		self.performSegueWithIdentifier("ShowInfo", sender: self.infoBtn)
	}

}
