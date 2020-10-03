import Foundation
import CoreGraphics

public struct SectionXs {
	let minX: CGFloat
	let maxX: CGFloat
	let date: Date
	var width: CGFloat { maxX - minX}
	
	func moveFor(points: CGFloat) -> SectionXs{
		SectionXs(minX: minX,
					maxX: maxX,
					date: date)
	}
}
