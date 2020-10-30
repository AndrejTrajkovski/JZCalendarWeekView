import Foundation
import CoreGraphics

public struct SectionXs {
	let minX: CGFloat
	let maxX: CGFloat
	
	public init(minX: CGFloat, maxX: CGFloat) {
		self.minX = minX
		self.maxX = maxX
	}
	
	var width: CGFloat { maxX - minX}
}
