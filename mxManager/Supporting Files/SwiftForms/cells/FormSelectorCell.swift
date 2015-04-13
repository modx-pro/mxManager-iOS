//
//  FormSelectorCell.swift
//  SwiftForms
//
//  Created by Miguel Ángel Ortuño Ortuño on 23/08/14.
//  Copyright (c) 2014 Miguel Angel Ortuño. All rights reserved.
//

import UIKit

class FormSelectorCell: FormValueCell {
    
    /// MARK: FormBaseCell

	override func configure() {
		super.configure()
		accessoryType = .None
	}
    
    override func update() {
        super.update()
        
        titleLabel.text = rowDescriptor.title

        var title: String!
        
        if let selectedValues = rowDescriptor.value as? NSArray { // multiple values
            
            let indexedSelectedValues = NSSet(array: selectedValues as [AnyObject])
            
            if let options = rowDescriptor.configuration[FormRowDescriptor.Configuration.Options] as? NSArray {
                for optionValue in options {
                    if indexedSelectedValues.containsObject(optionValue) {
						var optionTitle = rowDescriptor.titleForOptionValue(optionValue as! NSObject)
						if optionTitle != nil {
							optionTitle = optionTitle.componentsSeparatedByString("||")[0]
						}
                        if title != nil {
                            title = title + ", \(optionTitle)"
                        }
                        else {
                            title = optionTitle
                        }
                    }
                }
            }
        }
        else if let selectedValue = rowDescriptor.value { // single value
			title = rowDescriptor.titleForOptionValue(selectedValue)
			if title != nil {
				title = title.componentsSeparatedByString("||")[0]
			}
        }
        
        if title != nil && count(title) > 0 {
            valueLabel.text = title
            valueLabel.textColor = UIColor.blackColor()
        }
        else {
            valueLabel.text = rowDescriptor.configuration[FormRowDescriptor.Configuration.Placeholder] as? String
            valueLabel.textColor = UIColor.lightGrayColor()
        }
    }
    
    override class func formViewController(formViewController: FormViewController, didSelectRow selectedRow: FormBaseCell) {
        if let row = selectedRow as? FormSelectorCell {
            
            formViewController.view.endEditing(true)
            
            var selectorClass: UIViewController.Type!
            
            if let selectorControllerClass: AnyClass = row.rowDescriptor.configuration[FormRowDescriptor.Configuration.SelectorControllerClass] as? AnyClass {
                selectorClass = selectorControllerClass as? UIViewController.Type
            }
            else { // fallback to default cell class
                selectorClass = FormOptionsSelectorController.self
            }
            
            if selectorClass != nil {
                let selectorController = selectorClass()
                if let formRowDescriptorViewController = selectorController as? FormSelector {
                    formRowDescriptorViewController.formCell = row
					formViewController.navigationItem.backBarButtonItem = UIBarButtonItem.init(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)

					if let parent = formViewController.parentViewController as? ResourceTabPanel {
						if let controller = selectorController as? DefaultTable {
							controller.data = parent.data
							formViewController.navigationController?.pushViewController(controller, animated: true)
						}
					}
					else {
						formViewController.navigationController?.pushViewController(selectorController, animated: true)
					}
                }
                else {
                    fatalError("FormRowDescriptor.Configuration.SelectorControllerClass must conform to FormSelector protocol.")
                }
            }
        }
    }
}
