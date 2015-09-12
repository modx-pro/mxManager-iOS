//
//  Utils.swift
//  mxManager
//
//  Created by Василий Наумкин on 19.12.14.
//  Copyright (c) 2014 bezumkin. All rights reserved.
//

import UIKit
import Alamofire
import MBProgressHUD
import SwiftKeychain

class Utils: NSObject {

	class func dateFormat(date: String, dateStyle: NSDateFormatterStyle = .ShortStyle, timeStyle: NSDateFormatterStyle = .ShortStyle, dateFormat: String = "yyyy-MM-dd HH:mm:ss") -> String? {
		var formatter: NSDateFormatter = NSDateFormatter()
		formatter.dateFormat = dateFormat
		if let date = formatter.dateFromString(date) {
			formatter = NSDateFormatter()
			formatter.dateStyle = dateStyle
			formatter.timeStyle = timeStyle
			return formatter.stringFromDate(date)
		}
		return nil
	}

	class func lexicon(string: NSString, placeholders: [String:String] = [:]) -> String {
		if string == "" {
			return ""
		}

		var string = NSLocalizedString(string as String, tableName: "Main", comment: "") as NSString
		if placeholders.count > 0 {
			for (key, value) in placeholders {
				string = string.stringByReplacingOccurrencesOfString("[[+\(key)]]", withString: value)
			}
		}

		return string as String
	}

	class func alert(title: NSString, message: NSString, view: UIViewController, closure: (() -> Void)? = nil ) {
		let alert: UIAlertController = UIAlertController.init(
			title: Utils.lexicon(title) as String,
			message: Utils.lexicon(message) as String,
			preferredStyle: UIAlertControllerStyle.Alert
		)

		alert.addAction(UIAlertAction.init(
			title: Utils.lexicon("close") as String,
			style: UIAlertActionStyle.Cancel,
			handler: closure != nil
				? { (alert: UIAlertAction!) in closure!() }
				: nil
		))

		alert.view.tintColor = Colors.defaultText()
		view.presentViewController(alert, animated: true, completion: nil)
	}

	class func confirm(title: NSString, message: NSString, view: UIViewController, closure: (() -> Void)!) {
		let alert: UIAlertController = UIAlertController.init(
			title: Utils.lexicon(title) as String,
			message: Utils.lexicon(message) as String,
			preferredStyle: UIAlertControllerStyle.Alert
		)

		alert.addAction(UIAlertAction.init(
			title: Utils.lexicon("cancel") as String,
			style: UIAlertActionStyle.Cancel,
			handler: nil
		))
		alert.addAction(UIAlertAction.init(
			title: Utils.lexicon("ok") as String,
			style: UIAlertActionStyle.Default,
			handler: { (alert: UIAlertAction!) in closure() }
		))

		alert.view.tintColor = Colors.defaultText()
		view.presentViewController(alert, animated: true, completion: nil)
	}

	class func console(view: UIViewController, rows: NSArray) -> UIViewController {
		let text = NSMutableAttributedString.init() as NSMutableAttributedString

		for row in rows as! [NSDictionary] {
			let level = row["level"] as! String

			var attributes: [String: AnyObject] = [:]
			//attributes[NSFontAttributeName] = UIFont(name: "Courier New", size: 12)

			if level == "info" {
				attributes[NSForegroundColorAttributeName] = UIColor.grayColor()
			}
			else if level == "error" {
				attributes[NSForegroundColorAttributeName] = Colors.red()
			}
			else {
				attributes[NSForegroundColorAttributeName] = UIColor.blackColor()
			}
			let tmp = NSAttributedString.init(string: row["message"] as! String, attributes: attributes)
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

	class func showSpinner(view: UIView, animated: Bool = true) {
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

	class func hideSpinner(view: UIView, animated: Bool = true) {
		MBProgressHUD.hideAllHUDsForView(view, animated: animated)
	}

	class func getIcon(name: NSString) -> UIImage {
		let bundle = NSBundle.mainBundle() as NSBundle
		let path = bundle.pathForResource(name as String, ofType: "png")
		let icon = UIImage.init(contentsOfFile: path!) as UIImage!

		return icon.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
	}

	class func addSite(key: String, site: NSDictionary, notify: Bool = true) -> Bool {
		let keychain = Keychain.init() as Keychain
		let sites = [] as NSMutableArray
		sites.addObjectsFromArray(self.getSites() as [AnyObject])

		for (_, existing_site) in sites.enumerate() {
			if key == existing_site["key"] as! String {
				return self.updateSite(key, site: site)
			}
		}
		if site["key"] == nil {
			let tmp = [:] as NSMutableDictionary
			tmp.addEntriesFromDictionary(site as [NSObject : AnyObject])
			tmp["key"] = key
			sites.addObject(tmp)
		}
		else {
			sites.addObject(site)
		}

		if (keychain.update(ArchiveKey(keyName: "Sites", object: sites)) != nil) {
			return false
		}
		else if notify {
			NSNotificationCenter.defaultCenter().postNotificationName("SiteAdded", object: site)
		}
		return true
	}

	class func updateSite(key: String, site: NSDictionary, notify: Bool = true) -> Bool {
		let keychain = Keychain.init() as Keychain
		let sites = [] as NSMutableArray
		sites.addObjectsFromArray(self.getSites() as [AnyObject])

		for (index, existing_site) in sites.enumerate() {
			if key == existing_site["key"] as! String {
				/*
				if site["key"] == nil {
					let tmp = [:] as NSMutableDictionary
					tmp["key"] = key
					var site = tmp as NSDictionary
				}
				*/
				sites[index] = site
			}
		}

		if (keychain.update(ArchiveKey(keyName: "Sites", object: sites)) != nil) {
			return false
		}
		else if notify {
			NSNotificationCenter.defaultCenter().postNotificationName("SiteUpdated", object: site)
		}
		return true
	}

	class func removeSite(key: String, notify: Bool = true) -> Bool {
		let keychain = Keychain.init() as Keychain
		let sites = [] as NSMutableArray
		sites.addObjectsFromArray(self.getSites() as [AnyObject])

		for (index, site) in sites.enumerate() {
			if key == site["key"] as! String {
				sites.removeObjectAtIndex(index)
			}
		}

		if (keychain.update(ArchiveKey(keyName: "Sites", object: sites)) != nil) {
			return false
		}
		else if notify {
			NSNotificationCenter.defaultCenter().postNotificationName("SiteDeleted", object: key)
		}
		return true
	}

	class func getSites() -> NSArray {
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

	class func getPIN() -> String? {
		let keychain = Keychain.init() as Keychain
		let key = GenericKey(keyName: "PIN")

		return keychain.get(key).item?.value as? String
	}

	class func setPIN(pin: String) {
		let keychain = Keychain.init() as Keychain
		let key = GenericKey(keyName: "PIN", value: pin)

		if Utils.getPIN() != nil {
			keychain.remove(GenericKey(keyName: "PIN"))
		}
		keychain.add(key)
	}

	class func removePIN() {
		let keychain = Keychain.init() as Keychain
		keychain.remove(GenericKey(keyName: "PIN"))
	}

}