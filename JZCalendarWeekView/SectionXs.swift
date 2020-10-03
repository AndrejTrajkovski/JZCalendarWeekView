import Foundation
import CoreGraphics

public struct SectionXs {
	let minX: CGFloat
	let maxX: CGFloat
	var width: CGFloat { maxX - minX}
}
