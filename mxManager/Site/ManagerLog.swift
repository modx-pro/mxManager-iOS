//
//  ManagerLog.swift
//  mxManager
//
//  Created by Василий Наумкин on 01.02.15.
//  Copyright (c) 2015 bezumkin. All rights reserved.
//

import UIKit

class ManagerLog: DefaultTable {

	override func loadRows(spinner: Bool = true) {
		self.request = [
			"mx_action": "main/log/getlist",
			"start": 0 as NSNumber
		]
		super.loadRows(spinner: spinner)
	}

	override func loadMore() {
		self.request = [
			"mx_action": "main/log/getlist",
			"start": self.loaded as NSNumber
		]
		super.loadMore()
	}

	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! ManagerLogCell

		cell.data = self.rows[indexPath.row] as! NSDictionary
		cell.template(idx: indexPath.row)

		return cell
	}

}
