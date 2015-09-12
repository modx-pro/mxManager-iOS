//
//  Regex.swift
//  mxManager
//
//  Created by Василий Наумкин on 19.12.14.
//  Copyright (c) 2014 bezumkin. All rights reserved.
//

import Foundation

class Regex {
	let internalExpression: NSRegularExpression?
	let pattern: String

	init(_ pattern: String) {
		self.pattern = pattern
		do {
			try self.internalExpression = NSRegularExpression(pattern: pattern, options: .CaseInsensitive)
		}
		catch {
			self.internalExpression = nil
		}
	}

	func test(input: String) -> Bool {
		let matches = self.internalExpression?.matchesInString(input, options: [], range: NSMakeRange(0, input.characters.count))
		return matches?.count > 0
	}
}