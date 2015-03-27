//
//  ManagerLogCell.swift
//  mxManager
//
//  Created by Василий Наумкин on 01.02.15.
//  Copyright (c) 2015 bezumkin. All rights reserved.
//

import UIKit

class ManagerLogCell: DefaultCell {

	@IBOutlet var time: UILabel!
	@IBOutlet var user: UILabel!
	@IBOutlet var action: UILabel!
	@IBOutlet var item: UILabel!

	override func template(idx: Int = 0) {
		super.template(idx: idx)

		if self.data["occurred"] != nil {
			self.time.text = Utils.dateFormat(self.data["occurred"] as String)
		}
		if self.data["username"] != nil {
			self.user.text = self.data["username"] as String?
		}
		if self.data["action"] != nil {
			self.action.text = self.data["action"] as String?
		}
		if self.data["name"] != nil {
			self.item.text = self.data["name"] as String?
		}
	}

}
