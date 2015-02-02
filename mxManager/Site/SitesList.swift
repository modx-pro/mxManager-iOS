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

		NSNotificationCenter.defaultCenter().addObserver(self, selector: "loadRows", name:"SiteAdded", object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "loadRows", name:"SiteUpdated", object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "loadRows", name:"SiteDeleted", object: nil)

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
		let keychain = Keychain()
		if let tmp = keychain.get(ArchiveKey(keyName: "Sites")).item?.object as? NSDictionary {
			var rows = [] as NSMutableArray
			for (key, value) in tmp {
				var object = [:] as NSMutableDictionary
				object.addEntriesFromDictionary(value as NSDictionary)
				object["key"] = key
				rows.addObject(object)
			}
			self.rows = rows
		}

		self.tableView?.reloadData()
	}

	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let identifier = "cell"
		let cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as DefaultCell

		let data = self.rows[indexPath.row] as NSDictionary
		cell.data = data
		cell.textLabel?.text = data["site"] as NSString
		cell.detailTextLabel?.text = data["manager"] as NSString
		cell.template(idx:indexPath.row)

		return cell
	}

}
