//
//  FormTextCodeCell.swift
//  mxManager
//
//  Created by Василий Наумкин on 11.03.15.
//  Copyright (c) 2015 bezumkin. All rights reserved.
//


import UIKit

class FormTextCodeCell: FormBaseCell, UITextViewDelegate {

	/// MARK: Cell views

	let titleLabel: UILabel = UILabel()
	var textField: DefaultCodeView = DefaultCodeView(language: .C, theme: .Default)

	/// MARK: Properties

	private var customConstraints: [AnyObject]!

	/// MARK: FormBaseCell

	override func configure() {
		super.configure()

		selectionStyle = .None

		titleLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
		textField.setTranslatesAutoresizingMaskIntoConstraints(false)

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

		textField.delegate = self
	}

	override func update() {
		titleLabel.text = rowDescriptor.title
		textField.text = rowDescriptor.value as? String

		textField.secureTextEntry = false
		textField.autocorrectionType = .No
		textField.autocapitalizationType = .None
		textField.keyboardType = .Default

		//textField.inputAccessoryView = self.inputAccesoryView()
	}
/*
	func textViewShouldBeginEditing(textView: UITextView) -> Bool {
		if let parent = self.superview?.superview as? UITableView {
			if let controller = parent.dataSource as? UITableViewController {
				controller.navigationController?.setNavigationBarHidden(true, animated: true)
			}
		}
		return true
	}

	func textViewShouldEndEditing(textView: UITextView) -> Bool {
		if let parent = self.superview?.superview as? UITableView {
			if let controller = parent.dataSource as? UITableViewController {
				controller.navigationController?.setNavigationBarHidden(false, animated: true)
			}
		}
		return true
	}
*/
	override func constraintsViews() -> [String : UIView] {
		var views = ["titleLabel" : titleLabel, "textField" : textField]
		if self.imageView!.image != nil {
			views["imageView"] = imageView
		}
		return views
	}

	override func defaultVisualConstraints() -> [String] {

		if self.imageView!.image != nil {

			if titleLabel.text != nil && count(titleLabel.text!) > 0 {
				return ["H:[imageView]-[titleLabel]-[textField]-8-|"]
			}
			else {
				return ["H:[imageView]-[textField]-16-|"]
			}
		}
		else {
			if titleLabel.text != nil && count(titleLabel.text!) > 0 {
				return ["H:|-8-[titleLabel]-[textField]-8-|"]
			}
			else {
				return ["H:|-8-[textField]-8-|"]
			}
		}
	}

	/// MARK: UITextViewDelegate

	func textViewDidChange(textView: UITextView) {
		let trimmedText = textView.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
		rowDescriptor.value = count(trimmedText) > 0 ? trimmedText : nil
	}

	/*
	override func inputAccesoryView() -> UIToolbar {
		let flexible = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
		let doneButton = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: "handleDoneAction:")

		let actionBar: UIToolbar = UIToolbar()
		actionBar.translucent = true
		actionBar.sizeToFit()
		actionBar.barStyle = .Default
		actionBar.tintColor = UIColor.blackColor()
		actionBar.items = [flexible, doneButton]

		return actionBar
	}

	override func handleDoneAction(_: UIBarButtonItem) {
		self.textField.resignFirstResponder()
	}
	*/
}
