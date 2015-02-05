//
//  SiteCell.swift
//  mxManager
//
//  Created by Василий Наумкин on 04.02.15.
//  Copyright (c) 2015 bezumkin. All rights reserved.
//

import UIKit

class SiteCell: DefaultCell {

	override func template(idx: Int = 0) {
		super.template(idx: idx)

		self.textLabel?.text = self.data["site"] as String?
		if self.data["version"] != nil {
			self.detailTextLabel?.text = self.data["version"] as String?
		}
		else {
			self.detailTextLabel?.text = ""
		}
	}

}
