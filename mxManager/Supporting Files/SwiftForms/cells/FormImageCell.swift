//
//  FormTextViewCell.swift
//  SwiftForms
//
//  Created by Joey Padot on 12/6/14.
//  Copyright (c) 2014 Miguel Angel Ortuño. All rights reserved.
//

import UIKit

class FormImageCell: FormBaseCell {
	/// MARK: Cell views

	let titleLabel: UILabel = UILabel()
	let imageField: UIImageView = UIImageView()

	/// MARK: Properties

	private var customConstraints: [AnyObject]!

	/// MARK: FormBaseCell

	override func configure() {
		super.configure()

		selectionStyle = .None

		titleLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
		imageField.setTranslatesAutoresizingMaskIntoConstraints(false)
		imageField.contentMode = UIViewContentMode.ScaleAspectFit

		titleLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)

		contentView.addSubview(titleLabel)
		contentView.addSubview(imageField)

		titleLabel.setContentHuggingPriority(251, forAxis: .Horizontal)
		titleLabel.setContentCompressionResistancePriority(250, forAxis: .Horizontal)
		imageField.setContentHuggingPriority(251, forAxis: .Horizontal)
		imageField.setContentCompressionResistancePriority(250, forAxis: .Horizontal)

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
		contentView.addConstraint(NSLayoutConstraint(item: imageField, attribute: .Top, relatedBy: .Equal, toItem: contentView, attribute: .Top, multiplier: 1.0, constant: 4.0))
		contentView.addConstraint(NSLayoutConstraint(item: contentView, attribute: .Bottom, relatedBy: .Equal, toItem: imageField, attribute: .Bottom, multiplier: 1.0, constant: 4.0))

		imageField.layer.cornerRadius = 5.0;
		imageField.layer.masksToBounds = true;
		imageField.layer.borderColor = Colors().borderColor().CGColor
		imageField.layer.borderWidth = 0.5;
		//imageField.backgroundColor = Colors().borderColor()
	}

	override func update() {
		titleLabel.text = rowDescriptor.title
	}

	override func constraintsViews() -> [String:UIView] {
		return ["titleLabel": titleLabel, "imageField": imageField]
	}

	override func defaultVisualConstraints() -> [String] {
		if titleLabel.text != nil && count(titleLabel.text!) > 0 {
			return ["H:|-8-[titleLabel]-[imageField]-8-|"]
		}
		else {
			return ["H:|-8-[imageField]-8-|"]
		}
	}

}
