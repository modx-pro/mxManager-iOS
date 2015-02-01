//
//  ResourcesList.swift
//  mxManager
//
//  Created by Василий Наумкин on 26.12.14.
//  Copyright (c) 2014 bezumkin. All rights reserved.
//

import UIKit
import Alamofire

class ResourcesList: DefaultView, UITableViewDataSource, UITableViewDelegate {

	var sections = [:]
	var contexts = []
	var collapsed = [:]
	var parent = 0
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

	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		self.navigationItem.backBarButtonItem = UIBarButtonItem.init(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)

		switch segue.identifier! {
		case "getResources":
			let controller = segue.destinationViewController as ResourcesList
			if sender is ResourceCell {
				let cell = sender as ResourceCell
				controller.data = self.data
				controller.parent = cell.data["id"] as Int
				controller.title = cell.data["pagetitle"] as? String
			}
			break;
		default:
			break;
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
		site.getResources(self.parent, offset:0, {
			data in
			let tmp = data["data"] as NSDictionary
			let rows = tmp["rows"] as NSArray
			self.total = tmp["total"] as Int
			self.count = tmp["count"] as Int
			// Split to contexts
			var contexts = [] as NSMutableArray
			var sections = [:] as NSMutableDictionary
			for row in rows as [NSDictionary] {
				var ctx = row["context_key"] as String
				if sections[ctx] == nil {
					contexts.addObject(ctx)
					sections[ctx] = [row] as NSMutableArray
				}
				else {
					var arr = sections[ctx] as NSMutableArray
					arr.addObject(row)
					sections[ctx] = arr
				}
			}
			self.contexts = contexts
			self.sections = sections
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

	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return self.contexts.count
	}

	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if self.collapsed[section] != nil {
			return 0
		}
		else {
			let ctx = self.contexts[section] as String
			let rows = self.sections[ctx] as NSArray
			return rows.count
		}
	}

	func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return self.contexts.count > 1
				? 50
				: 0
	}

	func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		if self.contexts.count <= 1 {
			return nil
		}

		let view = UITableViewHeaderFooterView.init(frame: CGRectMake(0, 0, tableView.bounds.size.width, 50)) as UITableViewHeaderFooterView
		view.contentView.backgroundColor = Colors().sectionBackground()

		let icon = UIImageView.init(image: Utils().getIcon("globe")) as UIImageView
		icon.tintColor = Colors().sectionText()
		icon.frame = CGRectMake(8, 13, 24, 24)
		icon.bounds = CGRectMake(8, 13, 24, 24)
		icon.contentMode = UIViewContentMode.ScaleAspectFit;
		view.addSubview(icon)

		let label = UILabel.init() as UILabel
		label.text = self.contexts[section] as NSString
		label.textColor = Colors().sectionText()
		label.frame = CGRectMake(40, 13, tableView.bounds.size.width, 24)
		label.bounds = CGRectMake(40, 13, tableView.bounds.size.width, 24)
		label.font = UIFont.systemFontOfSize(17);
		view.addSubview(label)

		// Add toggle indicator
		let toggle = self.collapsed[section] == nil
				? UIImageView.init(image: Utils().getIcon("chevron-down")) as UIImageView
				: UIImageView.init(image: Utils().getIcon("chevron-right")) as UIImageView
		toggle.tintColor = Colors().sectionText()
		toggle.contentMode = UIViewContentMode.ScaleAspectFit;
		view.addSubview(toggle)

		// Add separator
		let separator = UIView.init() as UIView
		separator.backgroundColor = Colors().sectionSeparator()
		view.addSubview(separator)

		// Add constraints
		let views: NSDictionary = ["toggle": toggle, "separator": separator]

		toggle.setTranslatesAutoresizingMaskIntoConstraints(false)
		toggle.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[toggle(16)]", options: NSLayoutFormatOptions(0), metrics: nil, views: views))
		toggle.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[toggle(16)]", options: NSLayoutFormatOptions(0), metrics: nil, views: views))
		view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-17-[toggle]", options: NSLayoutFormatOptions(0), metrics: nil, views: views))
		view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[toggle]-8-|", options: NSLayoutFormatOptions(0), metrics: nil, views: views))

		separator.setTranslatesAutoresizingMaskIntoConstraints(false)
		separator.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[separator(1)]", options: NSLayoutFormatOptions(0), metrics: nil, views: views))
		view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[separator]-0-|", options: NSLayoutFormatOptions(0), metrics: nil, views: views))
		view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[separator]", options: NSLayoutFormatOptions(0), metrics: nil, views: views))
		view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[separator]-0-|", options: NSLayoutFormatOptions(0), metrics: nil, views: views))

		// Add tap gesture
		let tapGesture = UITapGestureRecognizer.init(target: self, action: "toggleSection:")
		view.addGestureRecognizer(tapGesture);

		view.tag = section
		return view
	}

	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		//let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as ResourceCell
		let cell = ResourceCell.init(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "cell") as ResourceCell

		let ctx = self.contexts[indexPath.section] as String
		let rows = self.sections[ctx] as NSArray
		cell.data = rows[indexPath.row] as NSDictionary
		cell.template(idx: indexPath.row)

		return cell
	}

	func toggleSection(tap: UITapGestureRecognizer) {
		var collapsed = NSMutableDictionary.init() as NSMutableDictionary
		if tap.view?.tag != nil {
			collapsed.addEntriesFromDictionary(self.collapsed)

			let section = tap.view!.tag
			if collapsed[section] == nil {
				collapsed[section] = true
				tap.view!.hidden = true
			}
			else {
				collapsed.removeObjectForKey(section)
			}
			self.collapsed = collapsed
		}

		self.tableView?.reloadData()
	}

	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		let ctx = self.contexts[indexPath.section] as String
		let rows = self.sections[ctx] as NSArray
		let data = rows[indexPath.row] as NSDictionary

		if data["isfolder"] as Int == 1 {
			let cell = self.tableView(tableView, cellForRowAtIndexPath: indexPath) as ResourceCell
			self.performSegueWithIdentifier("getResources", sender: cell)
		}
	}

	func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
		let ctx = self.contexts[indexPath.section] as String
		let rows = self.sections[ctx] as NSArray
		let data = rows[indexPath.row] as NSDictionary
		let permissions = data["permissions"] as NSDictionary
		let id = data["id"] as Int

		var moreButton:UITableViewRowAction = UITableViewRowAction.init(style: UITableViewRowActionStyle.Default, title: Utils().lexicon("actions")) {
			(action, indexPath) -> Void in
			tableView.editing = false

			var sheet: UIAlertController = UIAlertController.init(
				title: data["pagetitle"] as String?,
				message: data["longtitle"] as String?,
				preferredStyle: UIAlertControllerStyle.ActionSheet
			)
			sheet.view.tintColor = Colors().defaultText()
			/*
			if permissions["view"] as Bool {
				sheet.addAction(self.addAction(id, action:"view"))
			}
			if permissions["edit"] as Bool {
				sheet.addAction(self.addAction(id, action:"edit"))
			}
			*/
			if data["published"] as Int == 1 && permissions["unpublish"] as Bool {
				sheet.addAction(self.addAction(id, action:"unpublish", indexPath:indexPath))
			}
			else if data["published"] as Int == 0 && permissions["publish"] as Bool {
				sheet.addAction(self.addAction(id, action:"publish", indexPath:indexPath))
			}
			if data["deleted"] as Int == 1 && permissions["undelete"] as Bool {
				sheet.addAction(self.addAction(id, action:"undelete", indexPath:indexPath))
			}
			else if data["deleted"] as Int == 0 && permissions["delete"] as Bool {
				sheet.addAction(self.addAction(id, action:"delete", indexPath:indexPath))
			}

			sheet.addAction(UIAlertAction.init(
				title: Utils().lexicon("cancel"),
				style: UIAlertActionStyle.Cancel,
				handler: nil
			))
			self.presentViewController(sheet, animated: true, completion: nil)
		}
		moreButton.backgroundColor = Colors().blue()

		return [moreButton]
	}

	func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
	}

	func addAction(id: Int, action: String, indexPath: NSIndexPath?) -> UIAlertAction {
		return UIAlertAction.init(
			title: Utils().lexicon(action),
			style: UIAlertActionStyle.Default,
			handler: {
				(alert: UIAlertAction!) in

				let site = Site.init(params: self.data) as Site
				let parameters = [
						"mx_action": "resource/" + action,
						"id": id as NSNumber,
				]
				Utils().showSpinner(self.view)
				site.Request(parameters, {
					data in
					if indexPath != nil {
						let row = data["data"] as NSDictionary
						let ctx = self.contexts[indexPath!.section] as String
						let sections = NSMutableDictionary.init() as NSMutableDictionary
						sections.addEntriesFromDictionary(self.sections)
						let rows = sections[ctx] as NSMutableArray
						rows[indexPath!.row] = row
						sections[ctx] = rows
						self.sections = sections
						if self.tableView != nil {
							self.tableView!.reloadRowsAtIndexPaths([indexPath!] as NSArray, withRowAnimation: UITableViewRowAnimation.Fade)
						}
					}
					Utils().hideSpinner(self.view)
				}, {
					data in
					Utils().hideSpinner(self.view)
					Utils().alert("", message: data["message"] as String, view: self)
				})
			}
		)
	}


	// Lazy isLoading
	func scrollViewDidScroll(scrollView: UIScrollView!) {
		if !self.isLoading && self.parent != 0 && self.count < self.total {
			let currentOffset = scrollView.contentOffset.y
			let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
			let deltaOffset = maximumOffset - currentOffset

			if deltaOffset <= 0 {
				self.loadMore()
			}
		}
	}

	func loadMore() {
		if self.isLoading || self.parent == 0 || self.count >= self.total {
			return;
		}
		self.isLoading = true
		self.tableFooterView?.hidden = false

		let site = Site.init(params: self.data) as Site
		site.getResources(self.parent, offset: self.count, {
			data in
			let tmp = data["data"] as NSDictionary
			let rows = tmp["rows"] as NSArray
			self.count += tmp["count"] as Int
			// Split to contexts
			var contexts = [] as NSMutableArray
			contexts.addObjectsFromArray(self.contexts)
			var sections = [:] as NSMutableDictionary
			sections.addEntriesFromDictionary(self.sections)

			for row in rows as [NSDictionary] {
				var ctx = row["context_key"] as String
				if sections[ctx] == nil {
					contexts.addObject(ctx)
					sections[ctx] = [row] as NSMutableArray
				}
				else {
					var arr = sections[ctx] as NSMutableArray
					arr.addObject(row)
					sections[ctx] = arr
				}
			}
			self.contexts = contexts
			self.sections = sections

			self.tableView?.reloadData();
			self.refreshControl?.endRefreshing()
			self.isLoading = false
			if self.tableFooterView != nil {
				if self.count >= self.total {
					self.tableView?.tableFooterView = UIView.init()
				}
			}
		}, {
			data in
			self.refreshControl?.endRefreshing()
			Utils().alert("", message: data["message"] as String, view: self)
			self.isLoading = false
			self.tableFooterView?.hidden = true
		})
	}

}