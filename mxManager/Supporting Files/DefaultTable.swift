//
//  DefaultTable.swift
//  mxManager
//
//  Created by Василий Наумкин on 01.02.15.
//  Copyright (c) 2014 bezumkin. All rights reserved.
//

import UIKit

class DefaultTable: DefaultView, UITableViewDataSource, UITableViewDelegate {

	var rows = []
	var isLoading = false
	var invokeEvent = ""
	var count = 0
	var total = 0
	var request:[String:AnyObject] = [:]
	@IBOutlet var tableView: UITableView?
	@IBOutlet var refreshControl: UIRefreshControl?
	@IBOutlet var tableFooterView: UIView?

	deinit {
		self.tableView?.delegate = nil
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		var refreshControl = UIRefreshControl.init() as UIRefreshControl
		refreshControl.addTarget(self, action: "refreshRows", forControlEvents: UIControlEvents.ValueChanged)
		self.refreshControl = refreshControl

		if self.tableView? != nil {
			self.tableView!.addSubview(self.refreshControl!)
			self.tableView!.separatorColor = Colors().cellSeparator()
			if self.tableView!.tableFooterView == nil {
				self.tableView!.tableFooterView = UIView.init()
			}
			self.loadRows()
		}

		if self.invokeEvent != "" {
			NSNotificationCenter.defaultCenter().addObserver(self, selector: "onLoadRows:", name: self.invokeEvent, object: nil)
		}
	}

	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)

		if self.invokeEvent != "" {
			NSNotificationCenter.defaultCenter().removeObserver(self, name: self.invokeEvent, object: nil)
		}
	}

	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.rows.count
	}

	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = DefaultCell.init(style: UITableViewCellStyle.Default, reuseIdentifier: "cell") as DefaultCell
		cell.template(idx: indexPath.row)

		return cell
	}

	func loadRows(spinner: Bool = true) {
		if self.isLoading {
			return
		}
		self.isLoading = true

		if spinner {
			Utils().showSpinner(self.view)
		}

		self.Request(self.request, {
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
			if self.invokeEvent != "" {
				NSNotificationCenter.defaultCenter().postNotificationName(self.invokeEvent, object: tmp)
			}
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

	func onLoadRows(notification: NSNotification) {
		// By default do nothing
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

		self.Request(self.request, {
			data in
			let tmp = data["data"] as NSDictionary
			let rows = [] as NSMutableArray
			rows.addObjectsFromArray(self.rows)
			rows.addObjectsFromArray(tmp["rows"] as NSArray)
			self.rows = rows
			self.total = tmp["total"] as Int
			self.count += tmp["count"] as Int

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
