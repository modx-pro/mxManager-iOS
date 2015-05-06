//
//  Colors.swift
//  mxManager
//
//  Created by Василий Наумкин on 31.01.15.
//  Copyright (c) 2015 bezumkin. All rights reserved.
//

import UIKit

class Colors {

	class func defaultText(alpha: CGFloat = 1) -> UIColor {
		return UIColor.init(red: 85 / 255, green: 108 / 255, blue: 136 / 255, alpha: alpha)
	}

	class func disabledText(alpha: CGFloat = 1) -> UIColor {
		return UIColor.init(red: 144 / 255, green: 166 / 255, blue: 187 / 255, alpha: alpha)
	}

	class func systemTint(alpha: CGFloat = 1) -> UIColor {
		return UIColor.init(red: 0, green: 122 / 255, blue: 1, alpha: 1)
	}

	class func tableAlternate(alpha: CGFloat = 1) -> UIColor {
		return UIColor.init(red: 245 / 255, green: 246 / 255, blue: 249 / 255, alpha: alpha)
	}

	class func blue(alpha: CGFloat = 1) -> UIColor {
		return UIColor.init(red: 54 / 255, green: 151 / 255, blue: 205 / 255, alpha: alpha)
	}

	class func red(alpha: CGFloat = 1) -> UIColor {
		return UIColor.init(red: 190 / 255, green: 0, blue: 0, alpha: alpha)
	}

	class func green(alpha: CGFloat = 1) -> UIColor {
		return UIColor.init(red: 50 / 255, green: 171 / 255, blue: 154 / 255, alpha: alpha)
	}

	class func borderColor(alpha: CGFloat = 1) -> UIColor {
		return UIColor.init(red: 205 / 255, green: 205 / 255, blue: 205 / 255, alpha: alpha)
	}

	class func sectionBackground(alpha: CGFloat = 1) -> UIColor {
		return UIColor.init(red: 240 / 255, green: 240 / 255, blue: 240 / 255, alpha: alpha)
	}

	class func sectionText(alpha: CGFloat = 1) -> UIColor {
		return UIColor.init(red: 68 / 255, green: 121 / 255, blue: 150 / 255, alpha: alpha)
	}

	class func cellSeparator(alpha: CGFloat = 1) -> UIColor {
		return UIColor.init(red: 234 / 255, green: 234 / 255, blue: 234 / 255, alpha: 1)
	}

	class func sectionSeparator(alpha: CGFloat = 1) -> UIColor {
		return UIColor.init(red: 230 / 255, green: 230 / 255, blue: 230 / 255, alpha: 1)
	}

}