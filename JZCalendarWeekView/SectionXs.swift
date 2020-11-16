import Foundation
import CoreGraphics

public struct SectionXs {
	let minX: CGFloat
	let maxX: CGFloat
	
	public init(minX: CGFloat, maxX: CGFloat) {
		self.minX = minX
		self.maxX = maxX
	}
	
	var midX: CGFloat { minX + (width / 2) }
	var width: CGFloat { maxX - minX}
}
