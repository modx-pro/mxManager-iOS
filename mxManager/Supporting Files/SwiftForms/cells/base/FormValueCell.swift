//
//  FormValueCell.swift
//  SwiftForms
//
//  Created by Miguel Ángel Ortuño Ortuño on 13/11/14.
//  Copyright (c) 2014 Miguel Angel Ortuño. All rights reserved.
//

import UIKit

class FormValueCell: FormBaseCell {
    
    /// MARK: Cell views
    
    let titleLabel: UILabel = UILabel()
    let valueLabel: DefaultLabelField = DefaultLabelField()
    
    /// MARK: Properties
    
    private var customConstraints: [AnyObject]!
    
    /// MARK: FormBaseCell
    
    override func configure() {
        super.configure()
        
        accessoryType = .DisclosureIndicator
        
        titleLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        valueLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        titleLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
        valueLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)

        contentView.addSubview(titleLabel)
        contentView.addSubview(valueLabel)

		titleLabel.setContentHuggingPriority(251, forAxis: .Horizontal)
		titleLabel.setContentCompressionResistancePriority(250, forAxis: .Horizontal)
		valueLabel.setContentHuggingPriority(251, forAxis: .Horizontal)
		valueLabel.setContentCompressionResistancePriority(250, forAxis: .Horizontal)

        // apply constant constraints
		contentView.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .Height, relatedBy: .Equal, toItem: contentView, attribute: .Height, multiplier: 1.0, constant: 0.0))
		if titleLabel.text != "" {
			let width = rowDescriptor.configuration[FormRowDescriptor.Configuration.LabelWidth] as! CGFloat
			let labelWidth = NSLayoutConstraint(item: titleLabel, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: width)
			labelWidth.priority = 750
			contentView.addConstraint(labelWidth)
		}
		else {
			contentView.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .CenterY, relatedBy: .Equal, toItem: contentView, attribute: .CenterY, multiplier: 1.0, constant: 0.0))
		}
		contentView.addConstraint(NSLayoutConstraint(item: valueLabel, attribute: .Top, relatedBy: .Equal, toItem: contentView, attribute: .Top, multiplier: 1.0, constant: 4.0))
		contentView.addConstraint(NSLayoutConstraint(item: contentView, attribute: .Bottom, relatedBy: .Equal, toItem: valueLabel, attribute: .Bottom, multiplier: 1.0, constant: 4.0))
    }
    
    override func constraintsViews() -> [String : UIView] {
        return ["titleLabel" : titleLabel, "valueLabel" : valueLabel]
    }
    
    override func defaultVisualConstraints() -> [String] {
        
        // apply default constraints
        var rightPadding = 0
        if accessoryType == .None {
            rightPadding = 8
        }
        
        if titleLabel.text != nil && count(titleLabel.text!) > 0 {
            return ["H:|-8-[titleLabel]-[valueLabel]-\(rightPadding)-|"]
        }
        else {
            return ["H:|-8-[valueLabel]-\(rightPadding)-|"]
        }
    }
}
