//
//  SiteMain.swift
//  mxManager
//
//  Created by Василий Наумкин on 24.12.14.
//  Copyright (c) 2014 bezumkin. All rights reserved.
//

import UIKit

class SiteMain: DefaultTable {

	var popup: UIViewController?

	required init(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		self.invokeEvent = "LoadSite"
	}

	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		self.navigationItem.backBarButtonItem = UIBarButtonItem.init(title:"", style:UIBarButtonItemStyle.Plain, target:nil, action:nil)

		let cell = sender as! DefaultCell
		var controller = segue.destinationViewController as! DefaultView
		controller.data = self.data
		controller.title = cell.textLabel?.text
	}

	// For clear cache log
	override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
		if self.popup != nil {
			let original_width = self.view.frame.size.width
			let original_height = self.view.frame.size.height
			let height = self.popup!.view.frame.height
			var width = original_height

			if original_height > original_width {
				width = original_height
			}
			self.popup!.view.frame = CGRectMake(0, 0, width - 20, height)
			self.popup!.view.bounds = CGRectMake(0, 0, width - 20, height)
		}
	}

	override func loadRows(spinner: Bool = false) {
		self.request = [
				"mx_action": "auth",
				"username": self.data["user"] as! String,
				"password": self.data["password"] as! String,
		]
		super.loadRows(spinner: spinner)
	}

	override func onLoadRows(notification: NSNotification) {
		if let object = notification.object as? NSDictionary {
			self.updateSite(object as NSDictionary)
		}
	}

	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let identifier = self.rows[indexPath.row] as! NSString

		let cell = tableView.dequeueReusableCellWithIdentifier(identifier as String, forIndexPath: indexPath) as! DefaultCell
		cell.template(idx:indexPath.row)

		return cell
	}

	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		let identifier = self.rows[indexPath.row] as! NSString

		if identifier == "view_site" {
			if self.data["site_url"] != nil {
				let url = NSURL(string: self.data["site_url"] as! String)
				UIApplication.sharedApplication().openURL(url!)
			}
		}
		else if identifier == "clear_cache" {
			Utils().showSpinner(self.view)
			self.Request(["mx_action": "main/clearcache"], success: {
				data in
				Utils().hideSpinner(self.view)
				if self.navigationController != nil {
					let popup = Utils().console(self.navigationController!, rows: data["data"] as! NSArray)
					popup.view.frame = CGRectMake(0, 0, self.view.frame.size.width - 20, popup.view.frame.size.height)
					popup.view.bounds = CGRectMake(0, 0, self.view.bounds.size.width - 20, popup.view.frame.size.height)
					self.popup = popup
				}
			}, failure: {
				data in
				Utils().hideSpinner(self.view)
				Utils().alert("", message:data["message"] as! String, view:self)
			})
		}
	}

	func updateSite(data: NSDictionary) {
		let site = [:] as NSMutableDictionary
		site.addEntriesFromDictionary(self.data as [NSObject : AnyObject])

		if data["site_url"] != nil {
			site["site_url"] = data["site_url"] as! String
		}
		if data["version"] != nil {
			site["version"] = data["version"] as! String
		}

		if Utils().updateSite(site["key"] as! String, site: site, notify: false) {
			self.data = site
		}
	}

}
