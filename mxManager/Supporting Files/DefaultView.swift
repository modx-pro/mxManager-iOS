//
//  DefaultView.swift
//  mxManager
//
//  Created by Василий Наумкин on 18.12.14.
//  Copyright (c) 2014 bezumkin. All rights reserved.
//

import UIKit

class DefaultView: UIViewController {

	var data = [:]
	@IBOutlet var tableView: UITableView?
	@IBOutlet var refreshControl: UIRefreshControl?
	@IBOutlet var tableFooterView: UIView?

	deinit {
		self.tableView?.delegate = nil
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		if self.tableView? != nil {
			self.tableView!.separatorColor = Colors().cellSeparator()
			if self.tableView!.tableFooterView == nil {
				self.tableView!.tableFooterView = UIView.init()
			}
		}
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}

	override func prefersStatusBarHidden() -> Bool {
		return false
	}

}
