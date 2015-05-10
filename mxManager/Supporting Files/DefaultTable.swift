//
//  DefaultTable.swift
//  mxManager
//
//  Created by Василий Наумкин on 01.02.15.
//  Copyright (c) 2014 bezumkin. All rights reserved.
//

import UIKit

class DefaultTable: DefaultView, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

	var rows = []
	var loaded = 0
	var total = 0
	var isLoading = false
	var invokeEvent = ""
	var invokeMoreEvent = ""
	var request:[String:AnyObject] = [:]

	var searchEnabled = false
	var searchQuery = ""
	var searchBar: UISearchBar?

	var refreshControl: UIRefreshControl
	var activityIndicator: UIActivityIndicatorView
	@IBOutlet var tableView: UITableView!
	@IBOutlet var tableHeaderView: UIView?
	@IBOutlet var tableFooterView: UIView?

	required init(coder aDecoder: NSCoder) {
		refreshControl = UIRefreshControl()
		activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
		tableView = UITableView(frame: CGRectMake(0, 0, 0, 0), style: UITableViewStyle.Plain)

		super.init(coder: aDecoder)

		refreshControl.addTarget(self, action: "refreshRows", forControlEvents: UIControlEvents.ValueChanged)
		activityIndicator.frame = CGRectMake(0, 0, 0, 40)
		activityIndicator.startAnimating()
		tableView.delegate = self
		tableView.dataSource = self
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
		if self.invokeMoreEvent != "" {
			NSNotificationCenter.defaultCenter().addObserver(self, selector: "onLoadRows:", name: self.invokeMoreEvent, object: nil)
		}
	}

	func prepareTable() {
		self.tableView.addSubview(self.refreshControl)

		if self.searchEnabled {
			self.addSearchBar()
		}

		let backgroundColor = Colors.sectionBackground()
		self.tableView.backgroundColor = backgroundColor

		if self.tableHeaderView == nil {
			let header = UIView.init() as UIView
			header.frame = CGRectMake(0, 0, 0, 5)
			header.backgroundColor = backgroundColor
			self.tableHeaderView = header
		}
		self.tableView.tableHeaderView = self.tableHeaderView

		if self.tableFooterView == nil {
			let footer = UIView.init() as UIView
			footer.frame = CGRectMake(0, 0, 0, 5)
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
		if self.invokeMoreEvent != "" {
			NSNotificationCenter.defaultCenter().removeObserver(self, name: self.invokeMoreEvent, object: nil)
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
			Utils.showSpinner(self.view)
		}

		self.Request(self.request, success: {
			(data: NSDictionary!) in
			if let tmp = data["data"] as? NSDictionary {
				if tmp["rows"] != nil {
					self.rows = tmp["rows"] as! NSArray
				}
				if tmp["total"] != nil {
					self.total = tmp["total"] as! Int
				}
				if tmp["count"] != nil {
					self.loaded = tmp["count"] as! Int
				}
				if self.invokeEvent != "" {
					NSNotificationCenter.defaultCenter().postNotificationName(self.invokeEvent, object: tmp)
				}
				self.tableView.reloadData()
			}
			if spinner {
				Utils.hideSpinner(self.view)
			}
			self.tableView.tableFooterView = self.loaded < self.total
				? self.activityIndicator
				: self.tableFooterView
			self.isLoading = false
			self.refreshControl.endRefreshing()
		}, failure: {
			(data: NSDictionary!) in
			if spinner {
				Utils.hideSpinner(self.view)
			}
			self.tableView.tableFooterView = self.tableFooterView
			self.isLoading = false
			self.refreshControl.endRefreshing()
			Utils.alert("", message: data["message"] as! String, view: self)
		})
	}

	func refreshRows() {
		self.loadRows(spinner: false)
	}

	func onLoadRows(notification: NSNotification) {
		// By default do nothing
	}

	// Lazy load
	func scrollViewDidScroll(scrollView: UIScrollView) {
		if !self.isLoading && self.loaded < self.total {
			let currentOffset = scrollView.contentOffset.y
			let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
			let deltaOffset = maximumOffset - currentOffset

			if deltaOffset <= 0 {
				self.loadMore()
			}
		}
	}

	func loadMore() {
		if self.isLoading || self.loaded >= self.total {
			return
		}
		self.isLoading = true

		self.Request(self.request, success: {
			(data: NSDictionary!) in
			if let tmp = data["data"] as? NSDictionary {
				let rows = [] as NSMutableArray
				if tmp["rows"] != nil {
					rows.addObjectsFromArray(self.rows as [AnyObject])
					rows.addObjectsFromArray(tmp["rows"] as! NSArray as [AnyObject])
					self.rows = rows
				}
				if tmp["total"] != nil {
					self.total = tmp["total"] as! Int
				}
				if tmp["count"] != nil {
					self.loaded += tmp["count"] as! Int
				}
				if self.invokeMoreEvent != "" {
					NSNotificationCenter.defaultCenter().postNotificationName(self.invokeMoreEvent, object: tmp)
				}
				self.tableView.reloadData()
			}
			self.tableView.tableFooterView = self.loaded < self.total
					? self.activityIndicator
					: self.tableFooterView
			self.isLoading = false
		}, failure: {
			(data: NSDictionary!) in
			self.tableView.tableFooterView = self.tableFooterView
			self.isLoading = false
			Utils.alert("", message: data["message"] as! String, view: self)
		})
	}

	func addSearchBar() {
		let searchBar: UISearchBar = UISearchBar(frame:CGRectMake(0, 0, 320, 44))

		searchBar.delegate = self
		searchBar.returnKeyType = UIReturnKeyType.Search
		searchBar.tintColor = Colors.defaultText()
		searchBar.placeholder = Utils.lexicon("search") as String

		searchBar.translucent = true
		searchBar.barTintColor = Colors.sectionBackground()
		searchBar.layer.borderColor = Colors.borderColor().CGColor
		searchBar.layer.borderWidth = 0.5

		self.searchBar = searchBar
		self.tableHeaderView = searchBar
	}

	func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
		self.searchBar!.setShowsCancelButton(true, animated: true)
		return true
	}

	func searchBarShouldEndEditing(searchBar: UISearchBar) -> Bool {
		self.searchBar!.setShowsCancelButton(false, animated: true)
		return true
	}

	func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {

		if /*count(searchText) >= 3 || */count(searchText) == 0 {
			self.searchQuery = searchText
			self.loadRows(spinner: false)
		}
	}

	func searchBarSearchButtonClicked(searchBar: UISearchBar) {
		self.view.endEditing(true)
		self.searchQuery = searchBar.text
		self.loadRows()
	}

	func searchBarCancelButtonClicked(searchBar: UISearchBar) {
		self.view.endEditing(true)
	}

}
