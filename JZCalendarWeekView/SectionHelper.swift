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

	static func calcDateToSectionsMap(events: [Date: [[JZBaseEvent]]], pageDates: [Date]) -> ([Date: [Int]], [Int: Date]) {
		var runningTotal = 0
		var result: [Date: [Int]] = [:]
		var viceVersa: [Int: Date] = [:]
		for pageDate in pageDates {
			let dateEvents = events[pageDate]
			let upper = (dateEvents?.count ?? 1) + runningTotal
			let sections = Array(runningTotal..<upper)
			result[pageDate] = sections
			sections.forEach {
				viceVersa[$0] = pageDate
			}
			runningTotal = upper
		}
		return (result, viceVersa)
	}
}
