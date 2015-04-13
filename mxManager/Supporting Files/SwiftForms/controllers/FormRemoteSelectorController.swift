//
//  FormRemoteSelectorController.swift
//  SwiftForms
//
//
//  Copyright (c) 2014 Miguel Angel Ortuño. All rights reserved.
//

import UIKit

class FormRemoteSelectorController: DefaultTable, FormSelector {

	/// MARK: FormSelector

	var formCell: FormBaseCell!

	/// MARK: Init

	init() {
		let data = NSMutableData()
		let archiver = NSKeyedArchiver(forWritingWithMutableData: data)
		archiver.finishEncoding()
		super.init(coder: NSKeyedUnarchiver(forReadingWithData: data))
	}

	required  init(coder aDecoder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}

	override func prepareTable() {
		super.prepareTable()

		self.tableView.setTranslatesAutoresizingMaskIntoConstraints(false)
		self.view.addSubview(self.tableView)

		self.view.addConstraint(NSLayoutConstraint(item: self.tableView, attribute: .Top, relatedBy: .Equal, toItem: self.view, attribute: .Top, multiplier: 1.0, constant: 0.0))
		self.view.addConstraint(NSLayoutConstraint(item: self.view, attribute: .Trailing, relatedBy: .Equal, toItem: self.tableView, attribute: .Trailing, multiplier: 1.0, constant: 0.0))

		self.view.addConstraint(NSLayoutConstraint(item: self.view, attribute: .Bottom, relatedBy: .Equal, toItem: self.tableView, attribute: .Bottom, multiplier: 1.0, constant: 0.0))
		self.view.addConstraint(NSLayoutConstraint(item: self.tableView, attribute: .Leading, relatedBy: .Equal, toItem: self.view, attribute: .Leading, multiplier: 1.0, constant: 0.0))

		self.title = formCell.rowDescriptor.title
	}

	/// MARK: UITableViewDelegate

	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

		let cell = tableView.cellForRowAtIndexPath(indexPath)

		var allowsMultipleSelection = false
		if let allowsMultipleSelectionValue = formCell.rowDescriptor.configuration[FormRowDescriptor.Configuration.AllowsMultipleSelection] as? Bool {
			allowsMultipleSelection = allowsMultipleSelectionValue
		}

		let options = formCell.rowDescriptor.configuration[FormRowDescriptor.Configuration.Options] as! NSArray
		let optionValue = options[indexPath.row] as! NSObject

		if allowsMultipleSelection {

			if formCell.rowDescriptor.value == nil {
				formCell.rowDescriptor.value = NSMutableArray()
			}

			if var selectedOptions = formCell.rowDescriptor.value as? NSMutableArray {

				if selectedOptions.containsObject(optionValue) {
					selectedOptions.removeObject(optionValue)
					cell?.accessoryType = .None
				}
				else {
					selectedOptions.addObject(optionValue)

					if let checkmarkAccessoryView = formCell.rowDescriptor.configuration[FormRowDescriptor.Configuration.CheckmarkAccessoryView] as? UIView {
						cell?.accessoryView = checkmarkAccessoryView
					}
					else {
						cell?.accessoryType = .Checkmark
					}
				}

				if selectedOptions.count > 0 {
					formCell.rowDescriptor.value = selectedOptions
				}
				else {
					formCell.rowDescriptor.value = nil
				}
			}
		}
		else {
			formCell.rowDescriptor.value = optionValue
		}

		formCell.update()

		if let closure = formCell.rowDescriptor.configuration[FormRowDescriptor.Configuration.AfterSelectClosure] as? SelectClosure {
			closure(controller: self, tableView: tableView, indexPath: indexPath)
		}

		if allowsMultipleSelection {
			tableView.deselectRowAtIndexPath(indexPath, animated: true)
		}
		else {
			self.navigationController?.popViewControllerAnimated(true)
		}
	}

	func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
		if let closure = formCell.rowDescriptor.configuration[FormRowDescriptor.Configuration.BeforeSelectClosure] as? SelectClosure {
			closure(controller: self, tableView: tableView, indexPath: indexPath)
			return nil
		}
		return indexPath
	}

}
