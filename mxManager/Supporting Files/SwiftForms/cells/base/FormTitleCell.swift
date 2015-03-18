//
//  FormTitleCell.swift
//  SwiftForms
//
//  Created by Miguel Ángel Ortuño Ortuño on 13/11/14.
//  Copyright (c) 2014 Miguel Angel Ortuño. All rights reserved.
//

import UIKit

class FormTitleCell: FormBaseCell {

    /// MARK: Cell views
    
    let titleLabel = UILabel()
    
    /// MARK: FormBaseCell
    
    override func configure() {
        super.configure()
        
        titleLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        titleLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)

		titleLabel.setContentHuggingPriority(500, forAxis: .Horizontal)
		titleLabel.setContentCompressionResistancePriority(1000, forAxis: .Horizontal)

		contentView.addSubview(titleLabel)

		// apply constant constraints
		contentView.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .Height, relatedBy: .Equal, toItem: contentView, attribute: .Height, multiplier: 1.0, constant: 0.0))
		if titleLabel.text != "" {
			let labelWidth = NSLayoutConstraint(item: titleLabel, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 100.0)
			labelWidth.priority = 750
			contentView.addConstraint(labelWidth)
		}
		else {
			contentView.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .CenterY, relatedBy: .Equal, toItem: contentView, attribute: .CenterY, multiplier: 1.0, constant: 0.0))
		}
    }
    
    override func constraintsViews() -> [String : UIView] {
        return ["titleLabel" : titleLabel]
    }
    
    override func defaultVisualConstraints() -> [String] {
        return ["H:|-8-[titleLabel]-8-|"]
    }
}
