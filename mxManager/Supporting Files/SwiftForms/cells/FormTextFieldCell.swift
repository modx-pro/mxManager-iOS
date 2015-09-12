//
//  FormTextFieldCell.swift
//  SwiftForms
//
//  Created by Miguel Ángel Ortuño Ortuño on 20/08/14.
//  Copyright (c) 2014 Miguel Angel Ortuño. All rights reserved.
//

import UIKit

class FormTextFieldCell: FormBaseCell, UITextFieldDelegate {

	/// MARK: Cell views

	let titleLabel: UILabel  = UILabel()
	var textField: DefaultTextField = DefaultTextField()

	/// MARK: Properties

	private var customConstraints: [AnyObject]!

	/// MARK: FormBaseCell

	override func configure() {
		super.configure()

		selectionStyle = .None

		titleLabel.translatesAutoresizingMaskIntoConstraints = false
		textField.translatesAutoresizingMaskIntoConstraints = false

		titleLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
		textField.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)

		contentView.addSubview(titleLabel)
		contentView.addSubview(textField)

		titleLabel.setContentHuggingPriority(251, forAxis: .Horizontal)
		titleLabel.setContentCompressionResistancePriority(250, forAxis: .Horizontal)
		textField.setContentHuggingPriority(251, forAxis: .Horizontal)
		textField.setContentCompressionResistancePriority(250, forAxis: .Horizontal)

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
		contentView.addConstraint(NSLayoutConstraint(item: textField, attribute: .Top, relatedBy: .Equal, toItem: contentView, attribute: .Top, multiplier: 1.0, constant: 4.0))
		contentView.addConstraint(NSLayoutConstraint(item: contentView, attribute: .Bottom, relatedBy: .Equal, toItem: textField, attribute: .Bottom, multiplier: 1.0, constant: 4.0))

		textField.addTarget(self, action: "editingChanged:", forControlEvents: UIControlEvents.EditingChanged)

		textField.delegate = self
	}

	override func update() {
		super.update()

		if let showsInputToolbar = rowDescriptor.configuration[FormRowDescriptor.Configuration.ShowsInputToolbar] as? Bool {
			if showsInputToolbar && textField.inputAccessoryView == nil {
				textField.inputAccessoryView = inputAccesoryView()
			}
		}

		titleLabel.text = rowDescriptor.title
		textField.text = rowDescriptor.value as? String
		textField.placeholder = rowDescriptor.configuration[FormRowDescriptor.Configuration.Placeholder] as? String

		textField.secureTextEntry = false
		textField.clearButtonMode = .WhileEditing
		textField.returnKeyType = .Done

		switch rowDescriptor.rowType {
		case .Text:
			textField.autocorrectionType = .Default
			textField.autocapitalizationType = .Sentences
			textField.keyboardType = .Default
		case .Number:
			textField.keyboardType = .NumberPad
		case .NumbersAndPunctuation:
			textField.keyboardType = .NumbersAndPunctuation
		case .Decimal:
			textField.keyboardType = .DecimalPad
		case .Name:
			textField.autocorrectionType = .No
			textField.autocapitalizationType = .Words
			textField.keyboardType = .Default
		case .Phone:
			textField.keyboardType = .PhonePad
		case .NamePhone:
			textField.autocorrectionType = .No
			textField.autocapitalizationType = .Words
			textField.keyboardType = .NamePhonePad
		case .URL:
			textField.autocorrectionType = .No
			textField.autocapitalizationType = .None
			textField.keyboardType = .URL
		case .Twitter:
			textField.autocorrectionType = .No
			textField.autocapitalizationType = .None
			textField.keyboardType = .Twitter
		case .Email:
			textField.autocorrectionType = .No
			textField.autocapitalizationType = .None
			textField.keyboardType = .EmailAddress
		case .ASCIICapable:
			textField.autocorrectionType = .No
			textField.autocapitalizationType = .None
			textField.keyboardType = .ASCIICapable
		case .Password:
			textField.secureTextEntry = true
			textField.clearsOnBeginEditing = false
		default:
			break
		}
	}

	override func constraintsViews() -> [String:UIView] {
		var views = ["titleLabel": titleLabel, "textField": textField]
		if self.imageView!.image != nil {
			views["imageView"] = imageView
		}
		return views
	}

	override func defaultVisualConstraints() -> [String] {
		if self.imageView!.image != nil {

			if titleLabel.text != nil && titleLabel.text!.characters.count > 0 {
				return ["H:[imageView]-[titleLabel]-[textField]-8-|"]
			}
			else {
				return ["H:[imageView]-[textField]-8-|"]
			}
		}
		else {
			if titleLabel.text != nil && titleLabel.text!.characters.count > 0 {
				return ["H:|-8-[titleLabel]-[textField]-8-|"]
			}
			else {
				return ["H:|-8-[textField]-8-|"]
			}
		}
	}

	override func firstResponderElement() -> UIResponder? {
		return textField
	}

	override class func formRowCanBecomeFirstResponder() -> Bool {
		return true
	}

	/// MARK: Actions

	func editingChanged(sender: UITextField) {
		let trimmedText = sender.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
		rowDescriptor.value = trimmedText.characters.count > 0 ? trimmedText : nil
	}

	func textFieldShouldReturn(textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		return true
	}

}