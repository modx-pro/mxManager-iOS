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

		NSNotificationCenter.defaultCenter().addObserver(self, selector: "loadRowsFromEvent", name:"SiteAdded", object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "loadRowsFromEvent", name:"SiteUpdated", object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "loadRowsFromEvent", name:"SiteDeleted", object: nil)

		self.loadRows()
	}

	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		self.navigationItem.backBarButtonItem = UIBarButtonItem.init(title:"", style:UIBarButtonItemStyle.Plain, target:nil, action:nil)

		if segue.identifier? == "ShowSite" {
			let cell = sender as DefaultCell
			var controller = segue.destinationViewController as SiteMain
			controller.data = cell.data as NSDictionary
		}
	}

	@IBAction func unwindFromViewController(sender: UIStoryboardSegue) {
	}

	override func loadRows(spinner: Bool = false) {
		let rows = Utils().getSites()
		if rows.count > 0 {
			self.rows = rows
			self.refreshControl?.endRefreshing()
			self.tableView?.reloadData()
		}
	}

	func loadRowsFromEvent() {
		self.loadRows()
	}

	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let identifier = "cell"
		let cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as DefaultCell

		let data = self.rows[indexPath.row] as NSDictionary
		cell.data = data
		cell.textLabel?.text = data["site"] as String?
		//cell.detailTextLabel?.text = data["manager"] as String?
		if data["version"] != nil {
			cell.detailTextLabel?.text = data["version"] as String?
		}
		else {
			cell.detailTextLabel?.text = ""
		}
		cell.template(idx:indexPath.row)

		return cell
	}

}
