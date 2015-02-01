//
//  SiteMain.swift
//  mxManager
//
//  Created by Василий Наумкин on 24.12.14.
//  Copyright (c) 2014 bezumkin. All rights reserved.
//

import UIKit

class SiteMain: DefaultView, UITableViewDelegate, UITableViewDataSource {

	var rows = []
	var popup: UIViewController?

	override func viewDidLoad() {
		super.viewDidLoad()

		self.updateTitle()
		self.loadRows()

		NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateSettings:", name:"SiteUpdated", object: nil)
	}

	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier! == "ShowSettings" {
			var controller = segue.destinationViewController as SiteSettings
			controller.data = self.data
		}
		else {
			let cell = sender as DefaultCell
			var controller = segue.destinationViewController as DefaultView
			controller.data = self.data

			controller.navigationItem.title = cell.textLabel?.text
			self.navigationItem.backBarButtonItem = UIBarButtonItem.init(title:"", style:UIBarButtonItemStyle.Plain, target:nil, action:nil)
		}
	}

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

	func loadRows() {
		Utils().showSpinner(self.view)
		Site.init(params: self.data).Auth({
			data in
				self.rows = data["data"] as NSArray
				self.tableView?.reloadData()
				Utils().hideSpinner(self.view)
		}, {
			data in
				Utils().hideSpinner(self.view)
				Utils().alert("", message: data["message"] as String, view: self)
		})
	}

	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.rows.count
	}

	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let identifier = self.rows[indexPath.row] as NSString

		let cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as DefaultCell
		cell.template(idx:indexPath.row)

		return cell
	}

	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		let identifier = self.rows[indexPath.row] as NSString

		if identifier == "clear_cache" {
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

	func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
		return self.tableFooterView?
	}

	func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		return 50
	}

	@IBAction func editSite() {
		self.performSegueWithIdentifier("ShowSettings", sender: nil)
	}

	@IBAction func deleteSite() {
		Utils().confirm("warning", message:"site_delete_confirm", view: self, { _ in
			if Utils().removeSite(self.data["key"] as NSString) {
				self.performSegueWithIdentifier("ExitView", sender: self)
			}
		})
	}

	func updateSettings(event: AnyObject) {
		if event.object != nil {
			if let object = event.object as? NSDictionary {
				self.data = object
				self.updateTitle()
				self.loadRows()
			}
		}
	}

	func updateTitle() {
		if self.data["site"] != nil {
			self.title = self.data["site"] as NSString
		}
	}

}
