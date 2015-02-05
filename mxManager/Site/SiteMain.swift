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

	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		self.navigationItem.backBarButtonItem = UIBarButtonItem.init(title:"", style:UIBarButtonItemStyle.Plain, target:nil, action:nil)

		let cell = sender as DefaultCell
		var controller = segue.destinationViewController as DefaultView
		controller.data = self.data
		controller.navigationItem.title = cell.textLabel?.text
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
		if self.isLoading {
			return
		}
		self.isLoading = true

		if spinner {
			Utils().showSpinner(self.view)
		}
		let site = Site.init(params: self.data) as Site
		self.request = [
				"mx_action": "auth",
				"username": self.data["user"] as String,
				"password": self.data["password"] as String,
		]
		site.Request(self.request, {
			data in
			let tmp = data["data"] as NSDictionary
			self.rows = tmp["sections"] as NSArray
			self.updateSite(tmp)

			self.tableView?.reloadData();
			if spinner {
				Utils().hideSpinner(self.view)
			}
			if self.tableFooterView != nil {
				if self.count < self.total {
					self.tableView?.tableFooterView = self.tableFooterView
				}
			}
			self.refreshControl?.endRefreshing()
			self.isLoading = false
		}, {
			data in
			if spinner {
				Utils().hideSpinner(self.view)
			}
			self.refreshControl?.endRefreshing()
			self.isLoading = false
			Utils().alert("", message: data["message"] as String, view: self)
		})
	}

	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let identifier = self.rows[indexPath.row] as NSString

		let cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as DefaultCell
		cell.template(idx:indexPath.row)

		return cell
	}

	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		let identifier = self.rows[indexPath.row] as NSString

		if identifier == "view_site" {
			if self.data["site_url"] != nil {
				let url = NSURL(string: self.data["site_url"] as String)
				UIApplication.sharedApplication().openURL(url!)
			}
		}
		else if identifier == "clear_cache" {
			let site = Site.init(params:self.data) as Site
			Utils().showSpinner(self.view)
			site.clearCache({
				data in
				Utils().hideSpinner(self.view)
				if self.navigationController != nil {
					let popup = Utils().console(self.navigationController!, rows: data["data"] as NSArray)
					popup.view.frame = CGRectMake(0, 0, self.view.frame.size.width - 20, popup.view.frame.size.height)
					popup.view.bounds = CGRectMake(0, 0, self.view.bounds.size.width - 20, popup.view.frame.size.height)
					self.popup = popup
				}
			}, {
				data in
				Utils().hideSpinner(self.view)
				Utils().alert("", message:data["message"] as String, view:self)
			})
		}
	}

	func updateSite(data: NSDictionary) {
		let site = [:] as NSMutableDictionary
		site.addEntriesFromDictionary(self.data)

		if data["site_url"] != nil {
			site["site_url"] = data["site_url"] as String
		}
		if data["version"] != nil {
			site["version"] = data["version"] as String
		}

		if Utils().updateSite(site["key"] as String, site: site, notify: false) {
			self.data = site
		}
	}

}
