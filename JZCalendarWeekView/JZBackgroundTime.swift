//

import Foundation

open class JZBackgroundTime: NSObject, NSCopying {
	
	public init(date: Date, start: DateComponents, end: DateComponents) {
		self.date = date
		self.start = start
		self.end = end
	}
	
	var date: Date
	var start: DateComponents
	var end: DateComponents
	
	open func copy(with zone: NSZone? = nil) -> Any {
		return JZBackgroundTime(date: date, start: start, end: end)
	}
}
