//
//  SiteSettings.swift
//  mxManager
//
//  Created by Василий Наумкин on 18.12.14.
//  Copyright (c) 2014 bezumkin. All rights reserved.
//

import UIKit

class SiteSettings: DefaultPanel {

	@IBOutlet var navigationBar: UINavigationBar!
	@IBOutlet var btnCancel: UIBarButtonItem!

	// Main fields
	@IBOutlet var fieldSite: UITextField!
	@IBOutlet var fieldManager: UITextField!
	@IBOutlet var fieldUser: UITextField!
	@IBOutlet var fieldPassword: UITextField!

	// Basic authentication
	@IBOutlet var fieldBaseAuth: UISwitch!
	@IBOutlet var fieldBaseUser: UITextField!
	@IBOutlet var fieldBasePassword: UITextField!
	@IBOutlet var labelBaseUser: UILabel!
	@IBOutlet var labelBasePassword: UILabel!

	override func viewDidLoad() {
		super.viewDidLoad()
		self.fixTopOffset(UIApplication.sharedApplication().statusBarOrientation.isLandscape)

		if self.data.count != 0 {
			self.setForm(self.data)
		}
	}

	override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
		self.fixTopOffset(toInterfaceOrientation.isLandscape)
	}

	func setForm(data: NSDictionary) {
		if data["site"] != nil {
			self.fieldSite.text = data["site"] as NSString
		}
		if data["manager"] != nil {
			self.fieldManager.text = data["manager"] as NSString
		}
		if data["user"] != nil {
			self.fieldUser.text = data["user"] as NSString
		}
		if data["password"] != nil {
			self.fieldPassword.text = data["password"] as NSString
		}
		if data["base_auth"] != nil && data["base_auth"] as Bool {
			self.fieldBaseAuth.setOn(true, animated: false)
			if data["base_user"] != nil {
				self.fieldBaseUser.text = data["base_user"] as NSString
				self.fieldBaseUser.hidden = false
			}
			if data["base_password"] != nil {
				self.fieldBasePassword.text = data["base_password"] as NSString
				self.fieldBasePassword.hidden = false
			}
		}
	}

	func checkForm() -> Bool {
		var hasError = false

		// Main fields
		if self.fieldSite.text == "" {
			hasError = true
			self.fieldSite.markError(true)
		}
		else {
			self.fieldSite.markError(false)
		}

		if self.fieldManager.text == "" || !Regex("\\w{1,}\\.\\w{2,}").test(self.fieldManager.text) {
			hasError = true
			self.fieldManager.markError(true)
		}
		else {
			self.fieldManager.markError(false)
		}

		if self.fieldUser.text == "" {
			hasError = true
			self.fieldUser.markError(true)
		}
		else {
			self.fieldUser.markError(false)
		}

		if self.fieldPassword.text == "" {
			hasError = true
			self.fieldPassword.markError(true)
		}
		else {
			self.fieldPassword.markError(false)
		}

		// Basic authentication
		if self.fieldBaseAuth.on {
			if self.fieldBaseUser.text == "" {
				hasError = true
				self.fieldBaseUser.markError(true)
			}
			else {
				self.fieldBaseUser.markError(false)
			}

			if self.fieldBasePassword.text == "" {
				hasError = true
				self.fieldBasePassword.markError(true)
			}
			else {
				self.fieldBasePassword.markError(false)
			}
		}

		return hasError == false
	}

	@IBAction func saveForm() {
		if !self.checkForm() {
			return
		}
		self.view.endEditing(true)

		let site = [
				"site": self.fieldSite.text,
				"manager": self.fieldManager.text,
				"user": self.fieldUser.text,
				"password": self.fieldPassword.text,
				"base_auth": self.fieldBaseAuth.on,
				"base_user": self.fieldBaseAuth.on ? self.fieldBaseUser.text : "",
				"base_password": self.fieldBaseAuth.on ? self.fieldBasePassword.text : "",
		] as NSMutableDictionary
		var key = NSUUID().UUIDString
		if self.data["key"] != nil {
			key = self.data["key"] as String
			site["key"] = key
		}

		let sites = Utils().getSites()
		if sites.count > 0 {
			for (index, existing_site) in enumerate(sites) {
				// Check for existing site with the same name or url
				let s = existing_site["site"] as NSString
				let m = existing_site["manager"] as NSString
				let s2 = self.fieldSite.text
				let m2 = self.fieldManager.text
				var message = ""
				if s.lowercaseString == s2.lowercaseString && key != existing_site["key"] as String {
					message = "site_err_site_ae"
				}
				else if m.lowercaseString == m2.lowercaseString && key != existing_site["key"] as String {
					message = "site_err_manager_ae"
				}
				if message != "" {
					Utils().alert("error", message: message, view: self)
					return
				}
			}
		}

		Utils().showSpinner(self.view)
		self.btnSave.enabled = false;
		self.btnCancel.enabled = false;
		self.data = site
		self.Request([
				"mx_action": "auth",
				"username": site["user"] as String,
				"password": site["password"] as String,
			], {
			data in
				if let tmp = data["data"] as? NSDictionary {
					if tmp["site_url"] != nil {
						site["site_url"] = tmp["site_url"] as String
					}
					if tmp["version"] != nil {
						site["version"] = tmp["version"] as String
					}
				}
				if Utils().addSite(key, site:site) {
					self.closePopup()
				}
				Utils().hideSpinner(self.view)
			}, {
			data in
				Utils().alert("", message: data["message"] as String, view: self)
				self.btnSave.enabled = true;
				self.btnCancel.enabled = true;
				Utils().hideSpinner(self.view)
		})
	}

	@IBAction func closePopup() {
		self.dismissViewControllerAnimated(true, nil)
	}

	func fixTopOffset(landscape: Bool) {
		let constraints = self.navigationBar.constraints()
		let constraint = constraints[0] as NSLayoutConstraint

		constraint.constant = landscape
				? 52.0
				: 64.0
	}

	@IBAction func switchBaseAuth(sender: UISwitch) {
		var enabled = sender.on as Bool

		self.fieldBaseUser.hidden = !enabled
		self.fieldBasePassword.hidden = !enabled
		self.labelBaseUser.hidden = !enabled
		self.labelBasePassword.hidden = !enabled
	}

}
