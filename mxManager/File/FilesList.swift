//
//  FilesList.swift
//  mxManager
//
//  Created by Василий Наумкин on 04.02.15.
//  Copyright (c) 2015 bezumkin. All rights reserved.
//

import UIKit

class FilesList: DefaultTable {

	@IBOutlet var btnAdd: UIBarButtonItem!
	var btnSave: UIAlertAction?
	var source = 0
	var path = ""
	var pathRelative = ""
	var permissions = [:]
	var selectedRow = NSIndexPath.init(index: 0)
	var tmpName = ""

	override init(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		self.invokeEvent = "LoadFiles"
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		NSNotificationCenter.defaultCenter().removeObserver(self, name:"FileUpdated", object: nil)
	}

	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		self.navigationItem.backBarButtonItem = UIBarButtonItem.init(title:"", style:UIBarButtonItemStyle.Plain, target:nil, action:nil)

		let cell = sender as FileCell

		if segue.identifier? == "getFiles" {
			var controller = segue.destinationViewController as FilesList
			controller.data = self.data
			let type = cell.data["type"] as String
			if type == "source" {
				controller.source = cell.data["id"] as Int
			}
			else if cell.data["type"] as String == "dir" {
				controller.source = cell.data["source"] as Int
				controller.path = cell.data["path"] as String
				controller.pathRelative = cell.data["pathRelative"] as String
				controller.permissions = cell.data["permissions"] as NSDictionary
			}
			controller.title = cell.data["name"] as? String
		}
		else if segue.identifier? == "showFile" {
			var controller = segue.destinationViewController as FilePanel
			controller.data = self.data
			controller.source = cell.data["source"] as Int
			controller.path = cell.data["path"] as String
			controller.pathRelative = cell.data["pathRelative"] as String
			controller.title = cell.data["name"] as? String
			if cell.data["action"] != nil {
				controller.action = cell.data["action"] as String
			}
			NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshRows", name:"FileUpdated", object: nil)
		}
	}

	@IBAction func unwindFromViewController(sender: UIStoryboardSegue) {
	}

	override func loadRows(spinner: Bool = true) {
		self.request = [
			"mx_action": "files/getlist",
			"source": self.source,
			"path": self.pathRelative,
		]
		super.loadRows(spinner: spinner)
	}

	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = FileCell.init(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "cell") as FileCell
		let data = self.rows[indexPath.row] as NSDictionary
		cell.data = data
		cell.template(idx: indexPath.row)

		return cell
	}

	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		self.selectedRow = indexPath
		let cell = self.tableView(tableView, cellForRowAtIndexPath: indexPath) as FileCell
		let data = cell.data as NSDictionary
		let permissions = data["permissions"] as NSDictionary

		if cell.accessoryType == UITableViewCellAccessoryType.DisclosureIndicator {
			self.performSegueWithIdentifier("getFiles", sender: cell)
		}
		else if permissions["update"] != nil {
			self.performSegueWithIdentifier("showFile", sender: cell)
		}
	}

	override func onLoadRows(notification: NSNotification) {
		if self.source > 0 {
			if self.permissions["create"] != nil || self.path == "" {
				self.btnAdd.enabled = true
			}
		}
		// Сайты с одним источником файлов, когда вместо списка sources возвращается сразу корневая директория
		else if self.total > 0 {
			if let row = self.rows[0] as? NSDictionary {
				if row["type"] != nil {
					self.btnAdd.enabled = (row["type"] as String) != "source"
				}
				if row["source"] != nil {
					self.source = row["source"] as Int
				}
				if row["permissions"] != nil {
					self.permissions = row["permissions"] as NSDictionary
				}
			}
		}
	}

	// Операции с файлами и директориями из строки таблицы

	func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
		self.selectedRow = indexPath
		let item = self.rows[indexPath.row] as NSDictionary
		let permissions = item["permissions"] as NSDictionary
		let type = item["type"] as String
		var buttons = [] as NSMutableArray

		if permissions["remove"] != nil && permissions["remove"] as Int == 1 {
			let btn: UITableViewRowAction = UITableViewRowAction.init(style: UITableViewRowActionStyle.Default, title: "      ") {
				(action, indexPath) -> Void in
				tableView.editing = false
				self.removeItem(item)
			}
			btn.backgroundColor = UIColor(patternImage: UIImage(named:"btn-delete")!)
			buttons.addObject(btn)
		}

		//if permissions["update"] != nil && permissions["update"] as Int == 1 {
			let btn: UITableViewRowAction = UITableViewRowAction.init(style: UITableViewRowActionStyle.Default, title: "      ") {
				(action, indexPath) -> Void in
				tableView.editing = false
				self.PopupWindow(action: "update", item: item, type: type)
			}
			btn.backgroundColor = UIColor(patternImage: UIImage(named: "btn-edit")!)
			buttons.addObject(btn)
		//}

		if permissions["create"] != nil && permissions["create"] as Int == 1 && type == "dir" {
			let btn: UITableViewRowAction = UITableViewRowAction.init(style: UITableViewRowActionStyle.Default, title: "      ") {
				(action, indexPath) -> Void in
				tableView.editing = false
				self.showAddMenu("create", item: item)
			}
			btn.backgroundColor = UIColor(patternImage: UIImage(named: "btn-add")!)
			buttons.addObject(btn)
		}

		return buttons
	}

	func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
	}

	// Создание директорий и файлов во всплывающем окне

	@IBAction func showAddMenuHere() {
		let item = [
			"type": "dir",
			"source": self.source,
			"path": self.path,
			"pathRelative": self.pathRelative,
			"permissions": self.permissions
		]
		self.showAddMenu("create", item: item)
	}

	func showAddMenu(action: String, item: NSDictionary) {
		let sheet: UIAlertController = UIAlertController.init(
			title: nil,
			message: nil,
			preferredStyle: UIAlertControllerStyle.ActionSheet
		)
		sheet.view.tintColor = Colors().defaultText()

		sheet.addAction(UIAlertAction.init(
		title: Utils().lexicon("create_dir"),
				style: UIAlertActionStyle.Default,
				handler: {
					(alert: UIAlertAction!) in
					self.PopupWindow(action: action, item: item, type: "dir")
				}
		))

		sheet.addAction(UIAlertAction.init(
			title: Utils().lexicon("new_file"),
			style: UIAlertActionStyle.Default,
			handler: {
				(alert: UIAlertAction!) in
				var cell = FileCell.init() as FileCell
				cell.data = [
					"type": "file",
					"action": "create",
					"source": item["source"] as Int,
					"path": item["path"] as String,
					"pathRelative": item["pathRelative"] as String,
					"title": Utils().lexicon("create_file")
				]
				self.performSegueWithIdentifier("showFile", sender: cell)
			}
		))

		/*
		sheet.addAction(UIAlertAction.init(
			title: Utils().lexicon("create_file"),
			style: UIAlertActionStyle.Default,
			handler: {
				(alert: UIAlertAction!) in
				self.PopupWindow(action: action, item: item, type: "file")
			}
		))
		*/

		sheet.addAction(UIAlertAction.init(
			title: Utils().lexicon("cancel"),
			style: UIAlertActionStyle.Cancel,
			handler: nil
		))

		self.presentViewController(sheet, animated: true, completion: nil)
	}

	func PopupWindow(action: String = "create", item: NSDictionary = [:], type: String = "dir") {
		var message: String
		var saveTitle: String
		if action == "create" {
			saveTitle = Utils().lexicon("create")
			message = type == "dir"
				? "create_dir_intro"
				: "create_file_intro"
		}
		else {
			saveTitle = Utils().lexicon("save")
			message = type == "dir"
				? "update_dir_intro"
				: "update_file_intro"
		}

		let window: UIAlertController = UIAlertController.init(
			title: "",
			message: Utils().lexicon(message),
			preferredStyle: UIAlertControllerStyle.Alert
		)
		window.view.tintColor = Colors().defaultText()

		let btnCancel = UIAlertAction.init(
			title: Utils().lexicon("cancel"),
			style: UIAlertActionStyle.Cancel,
			handler: {
				(alert: UIAlertAction!) in
				NSNotificationCenter.defaultCenter().removeObserver(self, name: UITextFieldTextDidChangeNotification, object: nil)
			}
		)
		window.addAction(btnCancel)

		self.btnSave = UIAlertAction.init(
			title: saveTitle,
			style: UIAlertActionStyle.Default,
			handler: {
				(alert: UIAlertAction!) in
				if window.textFields?[0] != nil {
					let textField = window.textFields![0] as UITextField
					if action == "create" {
						self.createItem(textField.text, item: item, type: type)
					}
					else {
						self.renameItem(textField.text, item: item)
					}
				}
				NSNotificationCenter.defaultCenter().removeObserver(self, name: UITextFieldTextDidChangeNotification, object: nil)
			}
		)
		window.addAction(self.btnSave!)

		window.addTextFieldWithConfigurationHandler{
			(textField: UITextField!) in
			NSNotificationCenter.defaultCenter().addObserver(
				self,
				selector: "alertTextFieldDidChange:",
				name: UITextFieldTextDidChangeNotification,
				object: textField
			)
			if action == "update" && item["name"] != nil {
				textField.text = item["name"] as String
				self.tmpName = textField.text
			}
			else {
				self.tmpName = ""
			}
		}
		//self.btnSave?.enabled = action != "create"
		self.btnSave?.enabled = false
		self.presentViewController(window, animated: true, completion: nil)
	}

	func alertTextFieldDidChange(notification: NSNotification) {
		if notification.object != nil {
			let textField = notification.object as UITextField
			self.btnSave?.enabled = textField.text != self.tmpName
		}
	}

	// Действия

	func createItem(name: String, item: NSDictionary, type: String = "dir") {
		let request = [
			"mx_action": "files/" + type + "/create",
			"name": name,
			"source": item["source"] as NSNumber,
			"path": item["pathRelative"] as NSString,
		]
		Utils().showSpinner(self.view)
		self.Request(request, {
			(data: NSDictionary!) in
			if request["path"] != self.pathRelative {
				Utils().hideSpinner(self.view, animated: false)
				if self.tableView != nil {
					let cell = self.tableView(self.tableView!, cellForRowAtIndexPath: self.selectedRow) as FileCell
					self.performSegueWithIdentifier("getFiles", sender: cell)
				}
			}
			else {
				self.loadRows()
			}
		}, {
			(data: NSDictionary!) in
			Utils().hideSpinner(self.view)
			Utils().alert("", message: data["message"] as String, view: self)
		})
	}

	func renameItem(name: String, item: NSDictionary) {
		let type = (item["type"] as String) == "dir"
			? "dir"
			: "file"
		let request = [
			"mx_action": "files/" + type + "/rename",
			"name": name,
			"source": item["source"] as NSNumber,
			"path": item["pathRelative"] as NSString,
		]
		Utils().showSpinner(self.view)
		self.Request(request, {
			(data: NSDictionary!) in
			self.loadRows()
		}, {
			(data: NSDictionary!) in
			Utils().hideSpinner(self.view)
			Utils().alert("", message: data["message"] as String, view: self)
		})
	}

	func removeItem(item: NSDictionary!) {
		let type = (item["type"] as String) == "dir"
				? "dir"
				: "file"
		let message = type == "dir"
			? "remove_dir_confirm"
			: "remove_file_confirm"
		let request = [
			"mx_action": "files/" + type + "/remove",
			"source": item["source"] as NSNumber,
			"path": type == "dir"
				? item["path"] as NSString
				: item["pathRelative"] as NSString
		]

		Utils().confirm(
			item["name"] as String,
			message: Utils().lexicon(message),
			view: self,
			closure: {
				_ in
				Utils().showSpinner(self.view)
				self.Request(request, {
					(data: NSDictionary!) in
					self.loadRows()
				}, {
					(data: NSDictionary!) in
					Utils().hideSpinner(self.view)
					Utils().alert("", message: data["message"] as String, view: self)
				})
			}
		)
	}

}