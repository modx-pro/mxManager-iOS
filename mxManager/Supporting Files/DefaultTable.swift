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
	var count = 0
	var total = 0
	var isLoading = false
	var invokeEvent = ""
	var request:[String:AnyObject] = [:]

	var refreshControl: UIRefreshControl
	var activityIndicator: UIActivityIndicatorView
	@IBOutlet var tableView: UITableView!
	@IBOutlet var tableHeaderView: UIView?
	@IBOutlet var tableFooterView: UIView?

	override init(coder aDecoder: NSCoder) {
		refreshControl = UIRefreshControl()
		activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)

		super.init(coder: aDecoder)

		refreshControl.addTarget(self, action: "refreshRows", forControlEvents: UIControlEvents.ValueChanged)
		activityIndicator.frame = CGRectMake(0, 0, 0, 40)
		activityIndicator.startAnimating()
	}

	deinit {
		self.tableView?.delegate = nil
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		self.prepareTable()
		self.loadRows()

		if self.invokeEvent != "" {
			NSNotificationCenter.defaultCenter().addObserver(self, selector: "onLoadRows:", name: self.invokeEvent, object: nil)
		}
	}

	func prepareTable() {
		self.tableView.addSubview(self.refreshControl)

		let backgroundColor = Colors().sectionBackground()
		self.tableView.backgroundColor = backgroundColor

		if self.tableHeaderView == nil {
			let header = UIView.init() as UIView
			header.frame = CGRectMake(0, 0, 0, 20)
			header.backgroundColor = backgroundColor
			self.tableHeaderView = header
		}
		self.tableView.tableHeaderView = self.tableHeaderView

		if self.tableFooterView == nil {
			let footer = UIView.init() as UIView
			footer.frame = CGRectMake(0, 0, 0, 20)
			footer.backgroundColor = backgroundColor
			self.tableFooterView = footer
		}
		self.tableView.tableFooterView = self.tableFooterView
	}

	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)

		if self.invokeEvent != "" {
			NSNotificationCenter.defaultCenter().removeObserver(self, name: self.invokeEvent, object: nil)
		}
	}

	@IBAction func unwindFromViewController(sender: UIStoryboardSegue) {
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
			(data: NSDictionary!) in
			if let tmp = data["data"] as? NSDictionary {
				if tmp["rows"] != nil {
					self.rows = tmp["rows"] as NSArray
				}
				if tmp["total"] != nil {
					self.total = tmp["total"] as Int
				}
				if tmp["count"] != nil {
					self.count = tmp["count"] as Int
				}
				self.tableView.reloadData();
				if self.invokeEvent != "" {
					NSNotificationCenter.defaultCenter().postNotificationName(self.invokeEvent, object: tmp)
				}
			}
			if spinner {
				Utils().hideSpinner(self.view)
			}
			self.tableView.tableFooterView = self.count < self.total
				? self.activityIndicator
				: self.tableFooterView?
			self.isLoading = false
			self.refreshControl.endRefreshing()
		}, {
			(data: NSDictionary!) in
			if spinner {
				Utils().hideSpinner(self.view)
			}
			self.tableView.tableFooterView = self.tableFooterView?
			self.isLoading = false
			self.refreshControl.endRefreshing()
			Utils().alert("", message: data["message"] as String, view: self)
		})
	}

	func refreshRows() {
		self.loadRows(spinner: false)
	}

	func onLoadRows(notification: NSNotification) {
		// By default do nothing
	}

	// Lazy load
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

		self.Request(self.request, {
			(data: NSDictionary!) in
			if let tmp = data["data"] as? NSDictionary {
				let rows = [] as NSMutableArray
				if tmp["rows"] != nil {
					rows.addObjectsFromArray(self.rows)
					rows.addObjectsFromArray(tmp["rows"] as NSArray)
					self.rows = rows
				}
				if tmp["total"] != nil {
					self.total = tmp["total"] as Int
				}
				if tmp["count"] != nil {
					self.count += tmp["count"] as Int
				}
				self.tableView.reloadData();
			}
			self.tableView.tableFooterView = self.count < self.total
					? self.activityIndicator
					: self.tableFooterView?
			self.isLoading = false
		}, {
			(data: NSDictionary!) in
			self.tableView.tableFooterView = self.tableFooterView?
			self.isLoading = false
			Utils().alert("", message: data["message"] as String, view: self)
		})
	}

}
