//
//  ManagerLog.swift
//  mxManager
//
//  Created by Василий Наумкин on 01.02.15.
//  Copyright (c) 2015 bezumkin. All rights reserved.
//

import UIKit

class ManagerLog: DefaultView, UITableViewDataSource, UITableViewDelegate {

	var rows = []
	var isLoading = false
	var count = 0
	var total = 0

	override func viewDidLoad() {
		super.viewDidLoad()

		var refreshControl = UIRefreshControl.init() as UIRefreshControl
		refreshControl.addTarget(self, action: "refreshRows", forControlEvents: UIControlEvents.ValueChanged)
		self.refreshControl = refreshControl

		if self.tableView != nil {
			self.tableView!.addSubview(self.refreshControl!)
			self.loadRows()
		}
	}

	func loadRows(spinner: Bool = true) {
		if self.isLoading {
			return
		}
		self.isLoading = true

		if spinner {
			Utils().showSpinner(self.view)
		}
		let site = Site.init(params: self.data) as Site
		site.getManagerLog(start:0, {
			data in
			let tmp = data["data"] as NSDictionary
			self.rows = tmp["rows"] as NSArray
			self.total = tmp["total"] as Int
			self.count = tmp["count"] as Int

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

	func refreshRows() {
		self.loadRows(spinner: false)
	}

	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.rows.count
	}

	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		//let cell = ManagerLogCell.init(style: UITableViewCellStyle.Default, reuseIdentifier: "cell") as ManagerLogCell
		let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as ManagerLogCell

		cell.data = self.rows[indexPath.row] as NSDictionary
		cell.template(idx: indexPath.row)

		return cell
	}

	// Lazy isLoading
	func scrollViewDidScroll(scrollView: UIScrollView!) {
		if !self.isLoading && self.count < self.total {
			let currentOffset = scrollView.contentOffset.y
			let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
			let deltaOffset = maximumOffset - currentOffset

			if deltaOffset <= 0 {
				self.loadMore()
			}
		}
	}

	func loadMore() {
		if self.isLoading || self.count >= self.total {
			return;
		}
		self.isLoading = true
		self.tableFooterView?.hidden = false

		let site = Site.init(params: self.data) as Site
		site.getManagerLog(start: self.count, {
			data in
			let tmp = data["data"] as NSDictionary
			let rows = [] as NSMutableArray
			rows.addObjectsFromArray(self.rows)
			rows.addObjectsFromArray(tmp["rows"] as NSArray)
			self.rows = rows

			self.tableView?.reloadData();
			self.isLoading = false
			if self.tableFooterView != nil {
				if self.count >= self.total {
					self.tableView?.tableFooterView = UIView.init()
				}
			}
		}, {
			data in
			Utils().alert("", message: data["message"] as String, view: self)
			self.isLoading = false
			self.tableFooterView?.hidden = true
		})
	}

}
