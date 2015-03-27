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
import SwiftKeychain

class Utils: NSObject {

	func lexicon(string: NSString, placeholders: [String:String] = [:]) -> NSString {
		if string == "" {
			return ""
		}

		var string = NSLocalizedString(string, tableName: "Main", comment: "") as NSString
		if placeholders.count > 0 {
			for (key, value) in placeholders {
				string = string.stringByReplacingOccurrencesOfString("[[+\(key)]]", withString: value)
			}
		}

		return string
	}

	func alert(title: NSString, message: NSString, view: UIViewController, closure: (() -> Void)? = nil ) {
		let alert: UIAlertController = UIAlertController.init(
			title: self.lexicon(title),
			message: self.lexicon(message),
			preferredStyle: UIAlertControllerStyle.Alert
		)

		alert.addAction(UIAlertAction.init(
			title: self.lexicon("close"),
			style: UIAlertActionStyle.Cancel,
			handler: closure != nil
				? { (alert: UIAlertAction!) in closure!() }
				: nil
		))

		alert.view.tintColor = Colors().defaultText()
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

		alert.view.tintColor = Colors().defaultText()
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
			text.appendAttributedString(NSAttributedString.init(string: "\n"))
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
		let huds = MBProgressHUD.allHUDsForView(view) as NSArray
		if huds.count == 0 {
			let spinner = MBProgressHUD.showHUDAddedTo(view, animated: animated)
			spinner.mode = MBProgressHUDMode.Indeterminate
			spinner.backgroundColor = UIColor.init(red: 1, green: 1, blue: 1, alpha: 0.3)
			spinner.color = UIColor.clearColor()
			spinner.activityIndicatorColor = UIColor.blackColor()
			//loadingNotification.labelText = "Loading"
		}
	}

	func hideSpinner(view: UIView, animated: Bool = true) {
		MBProgressHUD.hideAllHUDsForView(view, animated: animated)
	}

	func getIcon(name: NSString) -> UIImage {
		let bundle = NSBundle.mainBundle() as NSBundle
		let path = bundle.pathForResource(name, ofType: "png")
		var icon = UIImage.init(contentsOfFile: path!) as UIImage!

		return icon.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
	}

	func addSite(key: String, site: NSDictionary, notify: Bool = true) -> Bool {
		let keychain = Keychain.init() as Keychain
		let sites = [] as NSMutableArray
		sites.addObjectsFromArray(self.getSites())

		for (index, existing_site) in enumerate(sites) {
			if key == existing_site["key"] as String {
				return self.updateSite(key, site: site)
			}
		}
		if site["key"] == nil {
			let tmp = [:] as NSMutableDictionary
			tmp.addEntriesFromDictionary(site)
			tmp["key"] = key
			sites.addObject(tmp)
		}
		else {
			sites.addObject(site)
		}

		if let error = keychain.update(ArchiveKey(keyName: "Sites", object: sites)) {
			return false
		}
		else if notify {
			NSNotificationCenter.defaultCenter().postNotificationName("SiteAdded", object: site)
		}
		return true
	}

	func updateSite(key: String, site: NSDictionary, notify: Bool = true) -> Bool {
		let keychain = Keychain.init() as Keychain
		let sites = [] as NSMutableArray
		sites.addObjectsFromArray(self.getSites())

		for (index, existing_site) in enumerate(sites) {
			if key == existing_site["key"] as String {
				if site["key"] == nil {
					let tmp = [:] as NSMutableDictionary
					tmp["key"] = key
					var site = tmp as NSDictionary
				}
				sites[index] = site
			}
		}

		if let error = keychain.update(ArchiveKey(keyName: "Sites", object: sites)) {
			return false
		}
		else if notify {
			NSNotificationCenter.defaultCenter().postNotificationName("SiteUpdated", object: site)
		}
		return true
	}

	func removeSite(key: String, notify: Bool = true) -> Bool {
		let keychain = Keychain.init() as Keychain
		let sites = [] as NSMutableArray
		sites.addObjectsFromArray(self.getSites())

		for (index, site) in enumerate(sites) {
			if key == site["key"] as String {
				sites.removeObjectAtIndex(index)
			}
		}

		if let error = keychain.update(ArchiveKey(keyName: "Sites", object: sites)) {
			return false
		}
		else if notify {
			NSNotificationCenter.defaultCenter().postNotificationName("SiteDeleted", object: key)
		}
		return true
	}

	func getSites() -> NSArray {
		let keychain = Keychain.init() as Keychain

		let sites = keychain.get(ArchiveKey(keyName: "Sites")).item?.object as? NSArray
		if sites != nil {
			return sites!
		}
		else {
			keychain.add(ArchiveKey(keyName: "Sites", object: []))
			return []
		}
	}

}