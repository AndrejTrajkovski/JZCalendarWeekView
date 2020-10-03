import Foundation 

open class SectionHelper<T: JZBaseEvent> {
	
	open class func groupEventsByPageAndSections<T: JZBaseEvent, SectionId: Hashable>(
		events: [T],
		grouping: KeyPath<T, SectionId>,
		sorting:
		@escaping ((key: SectionId, value: [T]), (key: SectionId, value: [T])) -> Bool)
		-> [[T]] {
			return Self.groupAndSortSections(grouping: grouping,
											 sorting: sorting)(events)
	}
	
	class func groupAndSortSections<T: JZBaseEvent, SectionId: Hashable>(
		grouping: KeyPath<T, SectionId>,
		sorting:
		@escaping ((key: SectionId, value: [T]), (key: SectionId, value: [T])) -> Bool)-> ([T]) -> [[T]] {
		return { events in
			let grouped = Dictionary.init(grouping: events,
										  by: { return $0[keyPath: grouping] })
			let sorted = grouped.sorted(by: sorting)
			return sorted.map(\.value)
		}
	}
	
	static func calcPageSectionXs(_ dateToSectionsMap: [Date: [Int]],
								  pageWidth: CGFloat) -> [Int: SectionInfo] {
		var pageSectionXx: [Int: SectionInfo] = [:]
		var minX: CGFloat = 0
		let sections = dateToSectionsMap.sorted(by: { $0.key < $1.key}).flatMap({ $0.value })
		for section in sections {
			let pageDict = dateToSectionsMap.first(where: { $0.value.contains(section)})!
			let width = (pageWidth / CGFloat(pageDict.value.count))
			let maxX = minX + width
			pageSectionXx[section] = SectionInfo(minX: minX, maxX: maxX, date: pageDict.key)
			minX = maxX
		}
		return pageSectionXx
	}
	
	static func calcDateToSectionsMap(events: [Date: [[JZBaseEvent]]], pageDates: [Date]) -> [Date: [Int]] {
		var runningTotal = 0
		var result: [Date: [Int]] = [:]
		for pageDate in pageDates {
			let dateEvents = events[pageDate]
			let upper = (dateEvents?.count ?? 1) + runningTotal
			result[pageDate] = Array(runningTotal..<upper)
			runningTotal = upper
		}
		return result
	}
}
