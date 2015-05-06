//
//  FilesList.swift
//  mxManager
//
//  Created by Василий Наумкин on 04.02.15.
//  Copyright (c) 2015 bezumkin. All rights reserved.
//

import UIKit

class FilesList: DefaultTable {

	var btnAdd: UIBarButtonItem!
	var btnSave: UIAlertAction?
	var source = 0
	var path = ""
	var pathRelative = ""
	var permissions = [:]
	var selectedRow = NSIndexPath.init(index: 0)
	//var tmpName = ""

	required init(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		self.invokeEvent = "LoadFiles"
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		let icon = UIImage.init(named: "icon-plus")
		self.btnAdd = UIBarButtonItem.init(image: icon, style: UIBarButtonItemStyle.Plain, target: self, action: "showAddMenuHere:")
		self.btnAdd.enabled = false
		self.navigationItem.setRightBarButtonItem(self.btnAdd, animated: false)

		NSNotificationCenter.defaultCenter().removeObserver(self, name:"FileUpdated", object: nil)
	}

	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		self.navigationItem.backBarButtonItem = UIBarButtonItem.init(title:"", style:UIBarButtonItemStyle.Plain, target:nil, action:nil)

		if segue.identifier == "showPopup" {
			if let controller = segue.destinationViewController as? PopupWindow {
				controller.data = sender as! NSDictionary
				controller.closure = {
					(textField: UITextField!) in
					if (controller.data["action"] as! String) == "create" {
						self.createItem(textField.text, item: controller.data["item"] as! NSDictionary, type: controller.data["type"] as! String)
					}
					else {
						self.renameItem(textField.text, item: controller.data["item"] as! NSDictionary)
					}
				}
			}
		}
		else {
			let cell = sender as! FileCell

			if segue.identifier == "getFiles" {
				let controller = segue.destinationViewController as! FilesList
				controller.data = self.data
				let type = cell.data["type"] as! String
				if type == "source" {
					controller.source = cell.data["id"] as! Int
					controller.permissions = cell.data["permissions"] as! NSDictionary
				}
				else if cell.data["type"] as! String == "dir" {
					controller.source = cell.data["source"] as! Int
					controller.path = cell.data["path"] as! String
					controller.pathRelative = cell.data["pathRelative"] as! String
					controller.permissions = cell.data["permissions"] as! NSDictionary
				}
				controller.title = cell.data["name"] as? String
			}
			else if segue.identifier == "showFile" {
				let controller = segue.destinationViewController as! FilePanel
				controller.data = self.data
				controller.source = cell.data["source"] as! Int
				controller.path = cell.data["path"] as! String
				controller.pathRelative = cell.data["pathRelative"] as! String
				controller.title = cell.data["name"] as? String
				if cell.data["action"] != nil {
					controller.action = cell.data["action"] as! String
				}
				NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshRows", name:"FileUpdated", object: nil)
			}
		}
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
		let data = self.rows[indexPath.row] as! NSDictionary
		cell.data = data
		cell.template(idx: indexPath.row)

		return cell
	}

	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		self.selectedRow = indexPath
		let cell = self.tableView(tableView, cellForRowAtIndexPath: indexPath) as! FileCell
		let data = cell.data as NSDictionary
		let permissions = data["permissions"] as! NSDictionary

		if cell.accessoryType == UITableViewCellAccessoryType.DisclosureIndicator {
			self.performSegueWithIdentifier("getFiles", sender: cell)
		}
		else if permissions["update"] != nil {
			self.performSegueWithIdentifier("showFile", sender: cell)
		}
	}

	override func onLoadRows(notification: NSNotification) {
		let data = notification.object as! NSDictionary

		if self.source == 0 && data["source"] != nil {
			self.source = data["source"] as! Int
		}
		// Сайты с одним источником файлов, когда вместо списка sources возвращается сразу корневая директория
		if data["permissions"] != nil {
			self.permissions =  data["permissions"] as! NSDictionary
		}

		self.btnAdd.enabled = self.canAdd(self.permissions)
	}

	func canAdd(permissions: NSDictionary) -> Bool {
		if permissions["create"] != nil {
			return permissions["create"] as! Bool
		}

		return false
	}

	// Операции с файлами и директориями из строки таблицы

	func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
		let item = self.rows[indexPath.row] as! NSDictionary
		let type = item["type"] as! String
		return type == "source"
				? UITableViewCellEditingStyle.None
				: UITableViewCellEditingStyle.Delete
	}

	func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
		self.selectedRow = indexPath
		let item = self.rows[indexPath.row] as! NSDictionary
		let permissions = item["permissions"] as! NSDictionary
		let type = item["type"] as! String
		var buttons = [] as NSMutableArray

		if permissions["remove"] != nil && permissions["remove"] as! Int == 1 {
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
				self.showPopupWindow(action: "update", item: item, type: type)
			}
			btn.backgroundColor = UIColor(patternImage: UIImage(named: "btn-edit")!)
			buttons.addObject(btn)
		//}

		if permissions["create"] != nil && permissions["create"] as! Int == 1 && type == "dir" {
			let btn: UITableViewRowAction = UITableViewRowAction.init(style: UITableViewRowActionStyle.Default, title: "      ") {
				(action, indexPath) -> Void in
				tableView.editing = false
				if let cell = self.tableView.cellForRowAtIndexPath(indexPath) {
					self.showAddMenu("create", item: item, sender: cell)
				}
			}
			btn.backgroundColor = UIColor(patternImage: UIImage(named: "btn-add")!)
			buttons.addObject(btn)
		}

		return buttons as [AnyObject]
	}

	func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
	}

	// Создание директорий и файлов во всплывающем окне

	func showAddMenuHere(sender: UIBarButtonItem!) {
		let item = [
			"type": "dir",
			"source": self.source,
			"path": self.path,
			"pathRelative": self.pathRelative,
			"permissions": self.permissions
		]
		self.showAddMenu("create", item: item, sender: sender)
	}

	func showAddMenu(action: String, item: NSDictionary, sender: AnyObject? = nil) {
		let sheet: UIAlertController = UIAlertController.init(
			title: nil,
			message: nil,
			preferredStyle: UIAlertControllerStyle.ActionSheet
		)
		sheet.view.tintColor = Colors.defaultText()

		if let popoverController = sheet.popoverPresentationController {
			if let btn = sender as? UIBarButtonItem {
				popoverController.barButtonItem = btn
			}
			else if let cell = sender as? UITableViewCell {
				popoverController.sourceView = cell.contentView
				popoverController.sourceRect = cell.contentView.bounds
			}
		}

		sheet.addAction(UIAlertAction.init(
		title: Utils.lexicon("create_dir") as String,
				style: UIAlertActionStyle.Default,
				handler: {
					(alert: UIAlertAction!) in
					self.showPopupWindow(action: action, item: item, type: "dir")
				}
		))

		sheet.addAction(UIAlertAction.init(
			title: Utils.lexicon("new_file") as String,
			style: UIAlertActionStyle.Default,
			handler: {
				(alert: UIAlertAction!) in
				var cell = FileCell.init() as FileCell
				cell.data = [
					"type": "file",
					"action": "create",
					"source": item["source"] as! Int,
					"path": item["path"] as! String,
					"pathRelative": item["pathRelative"] as! String,
					"title": Utils.lexicon("create_file")
				]
				self.performSegueWithIdentifier("showFile", sender: cell)
			}
		))

		/*
		sheet.addAction(UIAlertAction.init(
			title: Utils.lexicon("create_file"),
			style: UIAlertActionStyle.Default,
			handler: {
				(alert: UIAlertAction!) in
				self.showPopupWindow(action: action, item: item, type: "file")
			}
		))
		*/

		sheet.addAction(UIAlertAction.init(
			title: Utils.lexicon("cancel") as String,
			style: UIAlertActionStyle.Cancel,
			handler: nil
		))

		self.presentViewController(sheet, animated: true, completion: nil)
	}

	func showPopupWindow(action: String = "create", item: NSDictionary = [:], type: String = "dir") {
		var title: String
		var save: String
		if action == "create" {
			save = "create"
			title = type == "dir"
				? "create_dir_intro"
				: "create_file_intro"
		}
		else {
			save = "save"
			title = type == "dir"
				? "update_dir_intro"
				: "update_file_intro"
		}

		let data = [
			"title": Utils.lexicon(title),
			"save": Utils.lexicon(save),
			"text": (item["name"] as? String) == nil
				? ""
				: item["name"] as! String,
			"action": action,
			"item": item,
			"type": type
		]
		self.performSegueWithIdentifier("showPopup", sender: data)
	}

	/*
	func showPopupWindow(action: String = "create", item: NSDictionary = [:], type: String = "dir") {
		var message: String
		var saveTitle: String
		if action == "create" {
			saveTitle = Utils.lexicon("create")
			message = type == "dir"
					? "create_dir_intro"
					: "create_file_intro"
		}
		else {
			saveTitle = Utils.lexicon("save")
			message = type == "dir"
					? "update_dir_intro"
					: "update_file_intro"
		}

		let window: UIAlertController = UIAlertController.init(
		title: "",
				message: Utils.lexicon(message),
				preferredStyle: UIAlertControllerStyle.Alert
		)
		window.view.tintColor = Colors.defaultText()

		let btnCancel = UIAlertAction.init(
			title: Utils.lexicon("cancel"),
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
			let textField = notification.object as! UITextField
			self.btnSave?.enabled = textField.text != self.tmpName
		}
	}
	*/

	// Действия

	func createItem(name: String, item: NSDictionary, type: String = "dir") {
		let request = [
			"mx_action": "files/" + type + "/create",
			"name": name,
			"source": item["source"] as! NSNumber,
			"path": item["pathRelative"] as! NSString,
		]
		Utils.showSpinner(self.view)
		self.Request(request, success: {
			(data: NSDictionary!) in
			if request["path"] != self.pathRelative {
				Utils.hideSpinner(self.view, animated: false)
				if self.tableView != nil {
					let cell = self.tableView(self.tableView!, cellForRowAtIndexPath: self.selectedRow) as! FileCell
					self.performSegueWithIdentifier("getFiles", sender: cell)
				}
			}
			else {
				self.loadRows()
			}
		}, failure: {
			(data: NSDictionary!) in
			Utils.hideSpinner(self.view)
			Utils.alert("", message: data["message"] as! String, view: self)
		})
	}

	func renameItem(name: String, item: NSDictionary) {
		let type = (item["type"] as! String) == "dir"
			? "dir"
			: "file"
		let request = [
			"mx_action": "files/" + type + "/rename",
			"name": name,
			"source": item["source"] as! NSNumber,
			"path": item["pathRelative"] as! NSString,
		]
		Utils.showSpinner(self.view)
		self.Request(request, success: {
			(data: NSDictionary!) in
			self.loadRows()
			}, failure: {
			(data: NSDictionary!) in
			Utils.hideSpinner(self.view)
			Utils.alert("", message: data["message"] as! String, view: self)
		})
	}

	func removeItem(item: NSDictionary!) {
		let type = (item["type"] as! String) == "dir"
				? "dir"
				: "file"
		let message = type == "dir"
			? "remove_dir_confirm"
			: "remove_file_confirm"
		let request = [
			"mx_action": "files/" + type + "/remove",
			"source": item["source"] as! NSNumber,
			"path": type == "dir"
				? item["path"] as! NSString
				: item["pathRelative"] as! NSString
		]

		Utils.confirm(
			item["name"] as! String,
			message: message,
			view: self,
			closure: {
				_ in
				Utils.showSpinner(self.view)
				self.Request(request, success: {
					(data: NSDictionary!) in
					self.loadRows()
				}, failure: {
					(data: NSDictionary!) in
					Utils.hideSpinner(self.view)
					Utils.alert("", message: data["message"] as! String, view: self)
				})
			}
		)
	}

}