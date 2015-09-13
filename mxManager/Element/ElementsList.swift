//
//  ElementsList.swift
//  mxManager
//
//  Created by Василий Наумкин on 06.02.15.
//  Copyright (c) 2015 bezumkin. All rights reserved.
//

import UIKit

class ElementsList: DefaultTable {

	var btnAdd: UIBarButtonItem!
	@IBOutlet var typesControl: UISegmentedControl!
	@IBOutlet var typesWrapper: UIView!
	var btnSave: UIAlertAction?
	var type = ""
	var types = []
	var category = 0
	var permissions = [:]
	var tmpName = ""
	var selectedRow = NSIndexPath.init(index: 0)

	required init(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		self.invokeEvent = "LoadElements"
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		if self.types.count > 0 {
			self.setTypes()
		}

		let icon = UIImage.init(named: "icon-plus")
		self.btnAdd = UIBarButtonItem.init(image: icon, style: UIBarButtonItemStyle.Plain, target: self, action: "showAddMenuHere:")
		self.btnAdd.enabled = false
		self.navigationItem.setRightBarButtonItem(self.btnAdd, animated: false)

		NSNotificationCenter.defaultCenter().removeObserver(self, name: "ElementUpdated", object: nil)
	}

	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		self.navigationItem.backBarButtonItem = UIBarButtonItem.init(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)

		if segue.identifier == "showPopup" {
			if let controller = segue.destinationViewController as? PopupWindow {
				controller.data = sender as! NSDictionary
				controller.closure = {
					(textField: UITextField!) in
					if (controller.data["action"] as! String) == "create" {
						self.createItem(textField.text!, item: controller.data["item"] as! NSDictionary, type: controller.data["type"] as! String)
					}
					else {
						self.renameItem(textField.text!, item: controller.data["item"] as! NSDictionary)
					}
				}
			}
		}
		else {
			let cell = sender as! ElementCell
			if segue.identifier == "getElements" {
				let controller = segue.destinationViewController as! ElementsList
				controller.data = self.data

				if cell.data["permissions"] != nil {
					controller.permissions = cell.data["permissions"] as! NSDictionary
				}
				// Section
				if cell.data["id"] == nil {
					controller.types = self.types
					controller.type = cell.data["type"] as! String
					controller.category = 0
					controller.title = Utils.lexicon("categories") as String
				}
				// Category
				else {
					controller.types = self.types
					controller.type = self.type
					controller.category = cell.data["id"] as! Int
					controller.title = cell.data["name"] as? String
				}
			}
			else if segue.identifier == "showElement" {
				let controller = segue.destinationViewController as! ElementPanel
				controller.data = self.data

				controller.title = cell.data["name"] as? String
				controller.type = cell.data["type"] as! String
				controller.id = cell.data["id"] as! Int
				if cell.data["category"] != nil {
					controller.category = cell.data["category"] as! Int
				}
				if cell.data["action"] != nil {
					controller.action = cell.data["action"] as! String
				}
				NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshRows", name: "ElementUpdated", object: nil)
			}
		}
	}

	override func loadRows(spinner: Bool = true) {
		self.request = [
			"mx_action": "elements/getlist",
			"type": self.type,
			"category": self.category,
			"start": 0
		]
		super.loadRows(spinner)
	}

	override func loadMore() {
		self.request = [
			"mx_action": "elements/getlist",
			"type": self.type,
			"category": self.category,
			"start": self.loaded
		]
		super.loadMore()
	}

	override func onLoadRows(notification: NSNotification) {
		if self.type == "" {
			self.btnAdd.enabled = false
			let types = [] as NSMutableArray
			if let object = notification.object as? NSDictionary {
				for value in object["rows"] as! NSArray {
					if value["type"] != nil {
						types.addObject(value["type"] as! String)
					}
				}
				self.types = types
				self.setTypes()
			}
		}
		else {
			self.btnAdd.enabled = true
		}
	}

	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = ElementCell.init(style: UITableViewCellStyle.Default, reuseIdentifier: "cell") as ElementCell

		cell.data = self.rows[indexPath.row] as! NSDictionary
		cell.template(indexPath.row)

		return cell
	}

	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		let cell = self.tableView(tableView, cellForRowAtIndexPath: indexPath) as! ElementCell

		if cell.accessoryType == UITableViewCellAccessoryType.DisclosureIndicator {
			self.performSegueWithIdentifier("getElements", sender: cell)
		}
		else {
			self.performSegueWithIdentifier("showElement", sender: cell)
		}
	}

	// Операции с элементами и категориями из строки таблицы

	func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
		let item = self.rows[indexPath.row] as! NSDictionary
		return item["id"]  == nil
				? UITableViewCellEditingStyle.None
				: UITableViewCellEditingStyle.Delete
	}

	func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
		self.selectedRow = indexPath
		let item = self.rows[indexPath.row] as! NSDictionary
		let permissions = item["permissions"] as! NSDictionary
		let type = item["type"] as! String
		let buttons = [] as NSMutableArray

		if permissions["remove"] != nil && permissions["remove"] as! Int == 1 {
			let btn: UITableViewRowAction = UITableViewRowAction.init(style: UITableViewRowActionStyle.Default, title: "      ") {
				(action, indexPath) -> Void in
				tableView.editing = false
				self.removeItem(item)
			}
			btn.backgroundColor = UIColor(patternImage: UIImage(named: "btn-delete")!)
			buttons.addObject(btn)
		}

		if permissions["update"] != nil && permissions["update"] as! Int == 1 {
			let btn: UITableViewRowAction = UITableViewRowAction.init(style: UITableViewRowActionStyle.Default, title: "      ") {
				(action, indexPath) -> Void in
				tableView.editing = false
				self.showPopupWindow("update", item: item, type: type)
			}
			btn.backgroundColor = UIColor(patternImage: UIImage(named: "btn-edit")!)
			buttons.addObject(btn)
		}

		if permissions["create"] != nil && permissions["create"] as! Int == 1 {
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

	func setTypes() {
		self.typesControl.removeAllSegments()

		for (key, value) in self.types.enumerate() {
			self.typesControl.insertSegmentWithTitle(
				Utils.lexicon((value as! String) + "s") as String,
				atIndex: key,
				animated: false
			)
		}

		if self.type != "" {
			let selected = self.types.indexOfObject(self.type)
			self.typesControl.selectedSegmentIndex = selected
			self.tableView.tableHeaderView = self.typesWrapper
		}
		else {
			self.typesWrapper.hidden = true
			self.tableView.tableHeaderView = self.tableHeaderView
		}
	}

	@IBAction func changeType(sender: UISegmentedControl) {
		let selected = sender.selectedSegmentIndex
		if let type = self.types[selected] as? String {
			self.type = type as String
			self.loadRows()
		}
	}

	// Создание элементов и категорий во всплывающем окне

	func showAddMenuHere(sender: UIBarButtonItem!) {
		let item = [
			"id": self.category,
			"type": self.type,
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

		if let popoverController = sheet.popoverPresentationController {
			if let btn = sender as? UIBarButtonItem {
				popoverController.barButtonItem = btn
			}
			else if let cell = sender as? UITableViewCell {
				popoverController.sourceView = cell.contentView
				popoverController.sourceRect = cell.contentView.bounds
			}
		}

		if let permissions = item["permissions"] as? NSDictionary {
			let types = [
				"template", "tv", "chunk", "snippet", "plugin", "category"
			]
			for (_, value) in types.enumerate() {
				let type = value as String
				if permissions["new_" + type] != nil && permissions["new_" + type] as! Bool {
					if action == "update" || type == "category" {
						sheet.addAction(UIAlertAction.self(
							title: Utils.lexicon(action + "_" + type) as String,
							style: UIAlertActionStyle.Default,
							handler: {
								(alert: UIAlertAction!) in
								self.showPopupWindow(action, item: item, type: type)
							}
						))
					}
					else {
						sheet.addAction(UIAlertAction(
							title: Utils.lexicon("create_" + type) as String,
							style: UIAlertActionStyle.Default,
							handler: {
								(alert: UIAlertAction!) in
								let cell = ElementCell.init() as ElementCell
								cell.data = [
									"name": "",
									"type": type,
									"id": 0,
									"action": action,
									"category": item["id"] as! Int,
									"title": Utils.lexicon("create_" + type)
								]
								self.performSegueWithIdentifier("showElement", sender: cell)
								//self.showPopupWindow(action: action, item: item, type: type)
							}
						))
					}
				}
			}
		}

		sheet.addAction(UIAlertAction.init(
			title: Utils.lexicon("cancel") as String,
			style: UIAlertActionStyle.Cancel,
			handler: nil
		))

		self.presentViewController(sheet, animated: true, completion: nil)
		sheet.view.tintColor = Colors.defaultText()
	}

	/*
	func showPopupWindow(action: String = "create", item: NSDictionary = [:], type: String = "dir") {
		var title: String
		var save: String
		if action == "create" {
			save = Utils.lexicon("create") as String
			title = "create_" + type + "_intro"
		}
		else {
			save = Utils.lexicon("save") as String
			title = "update_" + type + "_intro"
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
	*/

	func showPopupWindow(action: String = "create", item: NSDictionary = [:], type: String = "category") {
		var message: String
		var saveTitle: String
		if action == "create" {
			saveTitle = Utils.lexicon("create") as String
			message = "create_" + type + "_intro"
		}
		else {
			saveTitle = Utils.lexicon("save") as String
			message = "update_" + type + "_intro"
		}

		let window: UIAlertController = UIAlertController.init(
			title: "",
			message: Utils.lexicon(message) as String,
			preferredStyle: UIAlertControllerStyle.Alert
		)

		let btnCancel = UIAlertAction.init(
			title: Utils.lexicon("cancel") as String,
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
					let textField = window.textFields![0] 
					if action == "create" {
						self.createItem(textField.text!, item: item, type: type)
					}
					else {
						self.renameItem(textField.text!, item: item)
					}
				}
				NSNotificationCenter.defaultCenter().removeObserver(self, name: UITextFieldTextDidChangeNotification, object: nil)
			}
		)
		window.addAction(self.btnSave!)

		window.addTextFieldWithConfigurationHandler{
			(textField: UITextField!) in
			NSNotificationCenter.defaultCenter().addObserver(self, selector: "alertTextFieldDidChange:", name: UITextFieldTextDidChangeNotification, object: textField)
			if action == "update" && item["name"] != nil {
				textField.text = item["name"] as? String
				self.tmpName = textField.text!
			}
			else {
				self.tmpName = ""
			}
		}
		self.btnSave?.enabled = false
		self.presentViewController(window, animated: true, completion: nil)
		window.view.tintColor = Colors.defaultText()
	}

	func alertTextFieldDidChange(notification: NSNotification) {
		if notification.object != nil {
			let textField = notification.object as! UITextField
			self.btnSave?.enabled = textField.text != self.tmpName
		}
	}

	// Действия

	func createItem(name: String, item: NSDictionary, type: String = "category") {
		let request = [
			"mx_action": "elements/" + type + "/create",
			"name": name,
			"category": item["id"] as! NSNumber,
		]
		Utils.showSpinner(self.view)
		self.Request(request, success: {
			(data: NSDictionary!) in
			if request["category"] != self.category {
				Utils.hideSpinner(self.view, animated: false)
				if self.tableView != nil {
					let cell = self.tableView(self.tableView!, cellForRowAtIndexPath: self.selectedRow) as! ElementCell
					self.performSegueWithIdentifier("getElements", sender: cell)
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
		let type = item["type"] as! String
		let request = [
			"mx_action": "elements/" + type + "/update",
			"id": item["id"] as! NSNumber,
			"name": name,
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
		let type = item["type"] as! String
		let message = "remove_" + type + "_confirm"
		let request = [
			"mx_action": "elements/" + type + "/remove",
			"id": item["id"] as! NSNumber,
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
