//
//  FormDateCell.swift
//  SwiftForms
//
//  Created by Miguel Angel Ortuno on 22/08/14.
//  Copyright (c) 2014 Miguel Angel Ortuño. All rights reserved.
//

import UIKit

class FormDateCell: FormValueCell {

    /// MARK: Properties
    
    private var datePicker: UIDatePicker = UIDatePicker()
    private let hiddenTextField: UITextField = UITextField(frame: CGRectZero)
    private let defaultDateFormatter: NSDateFormatter = NSDateFormatter()
	private var startValue: NSDate?
    
    /// MARK: FormBaseCell
    
    override func configure() {
        super.configure()

		accessoryType = .None
		startValue = rowDescriptor.value as? NSDate

        contentView.addSubview(hiddenTextField)
        hiddenTextField.inputView = datePicker
        hiddenTextField.inputAccessoryView = self.inputAccesoryView()
        datePicker.datePickerMode = UIDatePickerMode.DateAndTime
		datePicker.addTarget(self, action: "valueChanged:", forControlEvents: .ValueChanged)
    }
    
    override func update() {
        super.update()
        
        if let showsInputToolbar = rowDescriptor.configuration[FormRowDescriptor.Configuration.ShowsInputToolbar] as? Bool {
            if showsInputToolbar && hiddenTextField.inputAccessoryView == nil {
                hiddenTextField.inputAccessoryView = inputAccesoryView()
            }
        }
        
        titleLabel.text = rowDescriptor.title
        
        switch rowDescriptor.rowType {
        case .Date:
            datePicker.datePickerMode = UIDatePickerMode.Date
            defaultDateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
            defaultDateFormatter.timeStyle = NSDateFormatterStyle.NoStyle
        case .Time:
            datePicker.datePickerMode = UIDatePickerMode.Time
            defaultDateFormatter.dateStyle = NSDateFormatterStyle.NoStyle
            defaultDateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
        default:
            datePicker.datePickerMode = UIDatePickerMode.DateAndTime
            defaultDateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
            defaultDateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
        }
        
        if rowDescriptor.value != nil {
            let date = rowDescriptor.value as? NSDate
            datePicker.date = date!
            valueLabel.text = self.getDateFormatter().stringFromDate(date!)
        }
    }
    
    override class func formViewController(formViewController: FormViewController, didSelectRow selectedRow: FormBaseCell) {
        
        let row: FormDateCell! = selectedRow as? FormDateCell
        
        if row.rowDescriptor.value == nil {
            let date = NSDate()
            row.rowDescriptor.value = date
            row.valueLabel.text = row.getDateFormatter().stringFromDate(date)
            row.update()
        }
        
        row.hiddenTextField.becomeFirstResponder()
    }
    
    override func firstResponderElement() -> UIResponder? {
        return hiddenTextField
    }
    
    override class func formRowCanBecomeFirstResponder() -> Bool {
        return true
    }
    
    /// MARK: Actions
    
    func valueChanged(sender: UIDatePicker) {
        rowDescriptor.value = sender.date
        valueLabel.text = getDateFormatter().stringFromDate(sender.date)
        update()
    }

	override func inputAccesoryView() -> UIToolbar {
		let actionBar: UIToolbar = UIToolbar()
		actionBar.translucent = true
		actionBar.sizeToFit()
		actionBar.barStyle = .Default
//		let buttons = NSMutableArray()
		var buttons: [UIBarButtonItem] = []

		if startValue != nil {
			let clearButton: UIBarButtonItem = UIBarButtonItem(title: Utils.lexicon("btn_clear") as String, style: .Plain, target: self, action: "handleClearAction:")
			clearButton.tintColor = Colors.defaultText()
			buttons.append(clearButton)
		}

		let flexible = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
		buttons.append(flexible)

		let cancelButton: UIBarButtonItem = UIBarButtonItem(title: Utils.lexicon("btn_cancel") as String, style: .Plain, target: self, action: "handleCancelAction:")
		cancelButton.tintColor = Colors.defaultText()
		buttons.append(cancelButton)

		actionBar.items = buttons
		return actionBar
	}

	func handleClearAction(sender: UIBarButtonItem) {
		rowDescriptor.value = ""
		valueLabel.text = nil

		hiddenTextField.resignFirstResponder()
	}

	func handleCancelAction(sender: UIBarButtonItem) {
		if startValue != nil {
			rowDescriptor.value = startValue
			valueLabel.text = getDateFormatter().stringFromDate(startValue!)
		}
		else {
			rowDescriptor.value = nil
			valueLabel.text = nil
		}

		hiddenTextField.resignFirstResponder()
	}

    /// MARK: Private interface
    
    private func getDateFormatter() -> NSDateFormatter {
        
        if let dateFormatter = self.rowDescriptor.configuration[FormRowDescriptor.Configuration.DateFormatter] as? NSDateFormatter {
            return dateFormatter
        }
        return defaultDateFormatter
    }
}
