public struct SectionInfo {
	let minX: CGFloat
	let maxX: CGFloat
	let date: Date
	var width: CGFloat { maxX - minX}
}
