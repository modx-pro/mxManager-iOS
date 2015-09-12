//
//  InfoView.swift
//  mxManager
//
//  Created by Василий Наумкин on 19.05.15.
//  Copyright (c) 2015 bezumkin. All rights reserved.
//

import UIKit

class InfoView: UIViewController {

	@IBOutlet var navigationBar: UINavigationBar!
	@IBOutlet var btnCancel: UIBarButtonItem!
	@IBOutlet var btnRestore: UIButton!
	@IBOutlet var textView: UITextView!

	override func shouldAutorotate() -> Bool {
		return false
	}

	override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
		return UIInterfaceOrientationMask.Portrait
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		self.btnRestore.setTitle(Utils.lexicon("info_restore"), forState: UIControlState.Normal)

		self.textView.text = Utils.lexicon("info_description", placeholders: ["version": MX_VERSION])
		self.textView.textAlignment = NSTextAlignment.Center
	}

	override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
		self.fixTopOffset(toInterfaceOrientation.isLandscape)
	}

	@IBAction func closePopup() {
		self.dismissViewControllerAnimated(true, completion: nil)
	}

	@IBAction func restorePurchases() {
		Utils.showSpinner(self.view)
		IAPManager.sharedManager.restoreCompletedTransactions {
			(error) -> Void in
			Utils.hideSpinner(self.view)
			if error != nil {
				Utils.alert(
					"error",
					message: (error!.userInfo[NSLocalizedDescriptionKey] != nil)
						? error!.userInfo[NSLocalizedDescriptionKey] as! String
						: "",
					view: self
				)
			}
			else {
				Utils.alert(
					"success",
					message: "info_restore_ok",
					view: self
				)
			}
		}
	}

	func fixTopOffset(landscape: Bool) {
		let constraints = self.navigationBar.constraints
		let constraint = constraints[0] 

		constraint.constant = landscape
				? 32.0
				: 64.0
	}

}
