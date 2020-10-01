import Foundation
import CoreGraphics

public struct SectionInfo {
	let minX: CGFloat
	let maxX: CGFloat
	let date: Date
	var width: CGFloat { maxX - minX}
	
	func moveFor(points: CGFloat) -> SectionInfo{
		SectionInfo(minX: minX + points,
					maxX: maxX + points,
					date: date)
	}
}
