//
//  FormSwitchCell.swift
//  SwiftForms
//
//  Created by Miguel Angel Ortuno on 21/08/14.
//  Copyright (c) 2014 Miguel Angel Ortuño. All rights reserved.
//

import UIKit

class FormSwitchCell: FormTitleCell {

    /// MARK: Cell views
    
    let switchView = UISwitch()

    /// MARK: FormBaseCell

    override func configure() {
        super.configure()

        selectionStyle = .None

		switchView.translatesAutoresizingMaskIntoConstraints = false
		contentView.addSubview(switchView)

		contentView.addConstraint(NSLayoutConstraint(item: switchView, attribute: .Top, relatedBy: .Equal, toItem: contentView, attribute: .Top, multiplier: 1.0, constant: 6.0))
		contentView.addConstraint(NSLayoutConstraint(item: contentView, attribute: .Bottom, relatedBy: .Equal, toItem: switchView, attribute: .Bottom, multiplier: 1.0, constant: 0.0))

		switchView.addTarget(self, action: #selector(FormSwitchCell.valueChanged(_:)), forControlEvents: .ValueChanged)
	}

    override func update() {
        super.update()

        titleLabel.text = rowDescriptor.title

        if rowDescriptor.value != nil {
            switchView.on = rowDescriptor.value as! Bool
        }
        else {
            switchView.on = false
            rowDescriptor.value = false
        }
    }

    /// MARK: Actions

    func valueChanged(_: UISwitch) {
        if switchView.on != rowDescriptor.value {
            rowDescriptor.value = switchView.on as Bool
        }
    }

	override func constraintsViews() -> [String : UIView] {
		return ["titleLabel" : titleLabel, "switchView": switchView]
	}

	override func defaultVisualConstraints() -> [String] {
		return ["H:|-8-[titleLabel]-[switchView]-8-|"]
	}
}
