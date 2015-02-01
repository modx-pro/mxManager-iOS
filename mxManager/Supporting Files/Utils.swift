//
//  Utils.swift
//  mxManager
//
//  Created by Василий Наумкин on 19.12.14.
//  Copyright (c) 2014 bezumkin. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import MBProgressHUD

class Utils: NSObject {

	func lexicon(string: NSString) -> NSString {
		if string != "" {
			return NSLocalizedString(string, tableName: "Main", comment: "")
		}
		else {
			return ""
		}
	}

	func alert(title: NSString, message: NSString, view: UIViewController) {
		let alert: UIAlertController = UIAlertController(
			title: self.lexicon(title),
			message: self.lexicon(message),
			preferredStyle: UIAlertControllerStyle.Alert
		)

		alert.addAction(UIAlertAction(
			title: self.lexicon("close"),
			style: UIAlertActionStyle.Cancel,
			handler: nil
		))

		view.presentViewController(alert, animated: true, completion: nil)
	}

	func confirm(title: NSString, message: NSString, view: UIViewController, closure: (() -> Void)!) {
		let alert: UIAlertController = UIAlertController.init(
			title: self.lexicon(title),
			message: self.lexicon(message),
			preferredStyle: UIAlertControllerStyle.Alert
		)

		alert.addAction(UIAlertAction.init(
			title: self.lexicon("cancel"),
			style: UIAlertActionStyle.Cancel,
			handler: nil
		))
		alert.addAction(UIAlertAction.init(
			title: self.lexicon("ok"),
			style: UIAlertActionStyle.Default,
			handler: { (alert: UIAlertAction!) in closure() }
		))

		view.presentViewController(alert, animated: true, completion: nil)
	}

	func console(view: UIViewController, rows: NSArray) -> UIViewController {
		var text = NSMutableAttributedString.init() as NSMutableAttributedString

		for row in rows as [NSDictionary] {
			var level = row["level"] as String

			var attributes = [:] as NSMutableDictionary
			//attributes[NSFontAttributeName] = UIFont(name: "Courier New", size: 12)

			if level == "info" {
				attributes[NSForegroundColorAttributeName] = UIColor.grayColor()
			}
			else if level == "error" {
				attributes[NSForegroundColorAttributeName] = Colors().red()
			}
			else {
				attributes[NSForegroundColorAttributeName] = UIColor.blackColor()
			}
			var tmp = NSAttributedString.init(string: row["message"] as String, attributes: attributes)
			text.appendAttributedString(tmp)
			text.appendAttributedString(NSAttributedString(string: "\n"))
		}

		let window = Console.init() as Console
		view.presentViewController(window, animated: true, completion: nil)
		if window.textLabel != nil {
			let size = window.textLabel!.font.pointSize
			let font = window.textLabel!.font.familyName
			let range = NSMakeRange(0, text.length)
			text.addAttribute(NSFontAttributeName, value: UIFont(name: font, size: size)!, range: range)
		}
		window.textLabel?.attributedText = text as NSAttributedString

		return window
	}

	func showSpinner(view: UIView, animated: Bool = true) {
		let spinner = MBProgressHUD.showHUDAddedTo(view, animated: animated)
		spinner.mode = MBProgressHUDModeIndeterminate
		spinner.backgroundColor = UIColor.init(red: 1, green: 1, blue: 1, alpha: 0.3)
		spinner.color = UIColor.clearColor()
		spinner.activityIndicatorColor = UIColor.blackColor()
		//loadingNotification.labelText = "Loading"
	}

	func hideSpinner(view: UIView) {
		MBProgressHUD.hideAllHUDsForView(view, animated: true)
	}

	func getIcon(name: NSString) -> UIImage {
		let bundle = NSBundle.mainBundle() as NSBundle
		let path = bundle.pathForResource(name, ofType: "png")
		var icon = UIImage.init(contentsOfFile: path!) as UIImage!

		return icon.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
	}

	func addSite(key: NSString, site: NSDictionary) -> Bool {
		let keychain = Keychain.init()
		var sites = [:] as NSMutableDictionary

		if let data = keychain.get(ArchiveKey(keyName: "Sites")).item?.object as? NSDictionary {
			if data[key] != nil {
				return self.updateSite(key, site: site)
			}
			sites.addEntriesFromDictionary(data)
		}
		else {
			keychain.add(ArchiveKey(keyName: "Sites", object: sites))
		}

		var object = [:] as NSMutableDictionary
		object.addEntriesFromDictionary(site)
		object["key"] = key
		sites[key] = object
		if let error = keychain.update(ArchiveKey(keyName: "Sites", object: sites)) {
			return false
		}
		else {
			NSNotificationCenter.defaultCenter().postNotificationName("SiteAdded", object: object)
			return true
		}
	}

	func updateSite(key: NSString, site: NSDictionary) -> Bool {
		let keychain = Keychain.init()
		var sites = [:] as NSMutableDictionary

		if let data = keychain.get(ArchiveKey(keyName: "Sites")).item?.object as? NSDictionary {
			if data[key] == nil {
				return false
			}
			sites.addEntriesFromDictionary(data)
		}
		else {
			return false
		}

		var object = [:] as NSMutableDictionary
		object.addEntriesFromDictionary(site)
		object["key"] = key
		sites[key] = object
		if let error = keychain.update(ArchiveKey(keyName: "Sites", object: sites)) {
			return false
		}
		else {
			NSNotificationCenter.defaultCenter().postNotificationName("SiteUpdated", object: object)
			return true
		}
	}

	func removeSite(key: NSString) -> Bool {
		let keychain = Keychain.init()
		var sites = [:] as NSMutableDictionary

		if let data = keychain.get(ArchiveKey(keyName: "Sites")).item?.object as? NSDictionary {
			if data[key] == nil {
				return false
			}
			for (tmp, value) in data {
				var key2 = tmp as NSString
				if key2 != key {
					sites[key2] = value
				}
			}
		}

		if let error = keychain.update(ArchiveKey(keyName: "Sites", object: sites)) {
			return false
		}
		else {
			NSNotificationCenter.defaultCenter().postNotificationName("SiteDeleted", object: key)
			return true
		}
	}

}