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

	static func calcPageSectionXsAndDates(_ dateToSectionsMap: [Date: [Int]],
										  pageWidth: CGFloat) -> ([Int: SectionXs], [Int: Date]) {
		var sectionDates: [Int: Date] = [:]
		var pageSectionXx: [Int: SectionXs] = [:]
		var minX: CGFloat = 42
		let sections = dateToSectionsMap.sorted(by: { $0.key < $1.key}).flatMap({ $0.value })
		for section in sections {
			let pageDict = dateToSectionsMap.first(where: { $0.value.contains(section)})!
			let width = (pageWidth / CGFloat(pageDict.value.count))
			let maxX = minX + width
			pageSectionXx[section] = SectionXs(minX: minX, maxX: maxX)
			minX = maxX
			sectionDates[section] = pageDict.key
		}
		return (pageSectionXx, sectionDates)
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
