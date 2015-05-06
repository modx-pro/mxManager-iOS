//
//  ResourceSettingsPanel.swift
//  mxManager
//
//  Created by Василий Наумкин on 25.03.15.
//  Copyright (c) 2015 bezumkin. All rights reserved.
//

import UIKit

class ResourceSettingsPanel: DefaultForm {

	var parent: ResourceTabPanel!
	var hiddenRows: [String:NSIndexPath] = [:]

	 required init(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		name = "settings"
	}

	override func viewDidLoad() {
		parent = self.parentViewController as! ResourceTabPanel
		super.viewDidLoad()
	}

	override func setFormValues(data: AnyObject) {
		let data = data as! NSDictionary
		let form: FormDescriptor = FormDescriptor()

		var section: FormSectionDescriptor = FormSectionDescriptor()
		for field in ["publishedon", "pub_date", "unpub_date"] {
			var tmp_params = NSMutableDictionary.init(dictionary: self.defaultParams)
			tmp_params["valueLabel.font"] = UIFont.systemFontOfSize(self.defaultTextFontSize)
			if data[field] != nil {
				let row = FormRowDescriptor.init(tag: field, rowType: FormRowType.DateAndTime, title: Utils.lexicon("resource_" + field) as String) as FormRowDescriptor
				row.configuration[FormRowDescriptor.Configuration.CellConfiguration] = tmp_params
				row.configuration[FormRowDescriptor.Configuration.Required] = false
				row.configuration[FormRowDescriptor.Configuration.LabelWidth] = 150.0 as CGFloat
				if let value = data[field] as? String {
					let formatter: NSDateFormatter = NSDateFormatter()
					formatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
					row.value = formatter.dateFromString(value)
				}
				else {
					row.value = nil
				}
				section.addRow(row)
			}
		}
		if section.rows.count > 0 {
			form.addSection(section)
		}

		section = FormSectionDescriptor()
		for field in ["parent", "template", "class_key", "content_type", "content_dispo"] {
			if data[field] != nil {
				let row = FormRowDescriptor.init(tag: field, rowType: FormRowType.MultipleSelector, title: Utils.lexicon("resource_" + field) as String) as FormRowDescriptor
				var tmp_params = NSMutableDictionary.init(dictionary: self.defaultParams)
				tmp_params["valueLabel.font"] = UIFont.systemFontOfSize(self.defaultTextFontSize)
				tmp_params["valueLabel.color"] = UIColor.blackColor()
				tmp_params["valueLabel.textAlignment"] = NSTextAlignment.Left.rawValue
				row.configuration[FormRowDescriptor.Configuration.CellConfiguration] = tmp_params
				row.configuration[FormRowDescriptor.Configuration.Required] = find(["class_key", "content_type"], field) != nil
				row.configuration[FormRowDescriptor.Configuration.AllowsMultipleSelection] = false
				row.configuration[FormRowDescriptor.Configuration.LabelWidth] = 150.0 as CGFloat
				if find(["parent", "template", "content_type"], field) != nil {
					row.value = data[field] as? Int
					row.configuration["id"] = data["id"] as! Int
					if field == "parent" {
						row.configuration[FormRowDescriptor.Configuration.SelectorControllerClass] = ResourceParentSelector.self
					}
					else if field == "content_type" {
						row.configuration[FormRowDescriptor.Configuration.SelectorControllerClass] = ResourceContentTypeSelector.self
					}
					else if field == "template" {
						//self.parent.template = data[field] as! Int
						row.configuration[FormRowDescriptor.Configuration.SelectorControllerClass] = ResourceTemplateSelector.self
						row.configuration[FormRowDescriptor.Configuration.BeforeSelectClosure] = {
							(controller: DefaultTable, tableView: UITableView, indexPath: NSIndexPath) in
							if self.parent.tvs && self.parent.tvs_loaded {
								Utils.confirm(
									"",
									message: "resource_template_confirm",
									view: controller,
									closure: {
										_ in
										tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: .None)
										if let tmp = controller as? ResourceTemplateSelector {
											tmp.tableView(tableView, didSelectRowAtIndexPath: indexPath)
										}
									}
								)
							}
							else {
								tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: .None)
								if let tmp = controller as? ResourceTemplateSelector {
									tmp.tableView(tableView, didSelectRowAtIndexPath: indexPath)
								}
							}
						} as SelectClosure
						row.configuration[FormRowDescriptor.Configuration.AfterSelectClosure] = {
							(controller: DefaultTable, tableView: UITableView, indexPath: NSIndexPath) in
							if let data = controller.rows[indexPath.row] as? NSDictionary {
								if let tvs = data["tvs"] as? Bool {
									self.parent.activateTVsTab(tvs)
								}
								else {
									self.parent.activateTVsTab(false)
								}
							}
						} as SelectClosure
						row.configuration[FormRowDescriptor.Configuration.DidUpdateClosure] = {
							(rowDescriptor: FormRowDescriptor) in
							self.parent.template = rowDescriptor.value as! Int
							if self.parent.tvs_loaded {
								if let tvs = self.parent.tabs["tvs"] as! ResourceTVsPanel! {
									tvs.loadData(spinner: false)
								}
							}
						} as UpdateClosure
					}
					row.configuration[FormRowDescriptor.Configuration.Options] = [row.value]
					row.configuration[FormRowDescriptor.Configuration.TitleFormatterClosure] = {
						(value: AnyObject!) in
						return data[field + "_title"] as? String
					} as TitleFormatterClosure
				}
				else if field == "class_key" {
					row.value = data[field] as! String
					row.configuration[FormRowDescriptor.Configuration.Options] = (data["classes"] as? NSArray) != nil
						? data["classes"] as! NSArray
						: []
					row.configuration[FormRowDescriptor.Configuration.TitleFormatterClosure] = {
						(value: AnyObject!) in
						if let type = value as? String {
							return Utils.lexicon(type) as String
						}
						return nil
					} as TitleFormatterClosure
					row.configuration[FormRowDescriptor.Configuration.DidUpdateClosure] = {
						(rowDescriptor: FormRowDescriptor) in
						self.parent.class_key = rowDescriptor.value as! String
						if let main = self.parent.tabs["main"] as! ResourceMainPanel! {
							main.setFormValues(main.getFormValues())
						}
					} as UpdateClosure
				}
				else if field == "content_dispo" {
					row.value = data[field] as? Int
					row.configuration[FormRowDescriptor.Configuration.Options] = [0, 1]
					row.configuration[FormRowDescriptor.Configuration.TitleFormatterClosure] = {
						(value: AnyObject!) in
						if let type = value as? Int {
							return Utils.lexicon("resource_content_dispo_" + String(type)) as String
						}
						return nil
					} as TitleFormatterClosure
				}
				section.addRow(row)
			}
		}
		for field in ["responseCode", "menuindex"] {
			if data[field] != nil {
				var params = NSMutableDictionary.init(dictionary: self.defaultParams)
				params["textField.font"] = UIFont.systemFontOfSize(self.defaultTextFontSize)
				var row: FormRowDescriptor
				if field == "menuindex" {
					row = FormRowDescriptor.init(tag: field, rowType: FormRowType.Number, title: Utils.lexicon("resource_" + field) as String) as FormRowDescriptor
					row.configuration[FormRowDescriptor.Configuration.Required] = true
					if let tmp = data[field] as? Int {
						row.value = String(tmp)
					}
				}
				else {
					row = FormRowDescriptor.init(tag: field, rowType: FormRowType.Name, title: Utils.lexicon("resource_" + field) as String) as FormRowDescriptor
					row.configuration[FormRowDescriptor.Configuration.Required] = false
					row.value = data[field] as? String
				}
				row.configuration[FormRowDescriptor.Configuration.CellConfiguration] = params
				row.configuration[FormRowDescriptor.Configuration.LabelWidth] = 150.0 as CGFloat
				section.addRow(row)
			}
		}
		if section.rows.count > 0 {
			form.addSection(section)
		}

		section = FormSectionDescriptor()
		for field in ["isfolder", "searchable", "richtext", "cacheable",
				"syncsite", "deleted", "show_in_tree", "uri_override"] {
			var tmp_params = NSMutableDictionary.init(dictionary: self.defaultParams)
			if data[field] != nil {
				let row = FormRowDescriptor.init(tag: field, rowType: FormRowType.BooleanSwitch, title: Utils.lexicon("resource_" + field) as String) as FormRowDescriptor
				var color: UIColor
				switch field {
					case "deleted":
						color = Colors.red()
						break
					case "syncsite":
						color = Colors.blue()
						break
					default:
						color = Colors.green()
				}
				tmp_params["switchView.onTintColor"] = color
				row.configuration[FormRowDescriptor.Configuration.CellConfiguration] = tmp_params
				row.configuration[FormRowDescriptor.Configuration.Required] = false
				row.configuration[FormRowDescriptor.Configuration.LabelWidth] = 150.0 as CGFloat
				row.value = data[field] as! Bool
				if field == "uri_override" {
					row.configuration[FormRowDescriptor.Configuration.DidUpdateClosure] = {
						(row: FormRowDescriptor) in
						if self.hiddenRows[field] != nil {
							if let indexPath = self.hiddenRows[field] as NSIndexPath! {
								if row.value as! Bool {
									self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Top)
									self.tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
								}
								else {
									self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Bottom)
								}
								let s: FormSectionDescriptor = self.form.sections[indexPath.section]
								let r: FormRowDescriptor = s.rows[indexPath.row]
								r.configuration[FormRowDescriptor.Configuration.Required] = row.value as! Bool
							}
						}
					} as UpdateClosure
				}
				section.addRow(row)
			}
		}
		if data["uri_override"] != nil && data["uri"] != nil {
			var field = "uri"
			var params = NSMutableDictionary.init(dictionary: self.defaultParams)
			params["textField.font"] = UIFont.systemFontOfSize(self.defaultTextFontSize)
			let row = FormRowDescriptor.init(tag: field, rowType: FormRowType.Name, title: Utils.lexicon("resource_" + field) as String) as FormRowDescriptor
			row.value = data[field] as? String
			row.configuration[FormRowDescriptor.Configuration.Required] = data["uri_override"] as! Bool
			row.configuration[FormRowDescriptor.Configuration.CellConfiguration] = params
			row.configuration[FormRowDescriptor.Configuration.LabelWidth] = 150.0 as CGFloat
			let indexPath = NSIndexPath.init(forRow: section.rows.count, inSection: form.sections.count)
			self.hiddenRows = ["uri_override": indexPath]
			section.addRow(row)
		}
		if section.rows.count > 0 {
			form.addSection(section)
		}

		self.form = form
		self.tableView.reloadData()
	}

	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		var number = super.tableView(tableView, numberOfRowsInSection: section)
		let values = self.getFormValues()
		for (key, indexPath: NSIndexPath) in self.hiddenRows {
			if indexPath.section == section && values[key] != nil && values[key] as! Bool == false {
				number -= 1
			}
		}
		return number
	}

	override func submitForm(sender: UIBarButtonItem!) {
		self.parent.submitForm(sender)
	}

	override func addSaveButton() {
		self.parent.addSaveButton()
	}

	override func addHideKeyboardButton() {
		self.parent.addHideKeyboardButton()
	}

}
