import Foundation

open class SectionWeekViewHelper {
	open class func groupEventsByPageAndSections<T: JZBaseEvent, SectionId: Hashable>(
		eventsBySection: [Date: [T]],
		grouping: KeyPath<T, SectionId>,
		sorting:
		@escaping ((key: SectionId, value: [T]), (key: SectionId, value: [T])) -> Bool)
		-> [Date: [[T]]] {
			let asdf = Self.groupAndSortSections(grouping: grouping,
												 sorting: sorting)
			let res: [Date: [[T]]] = eventsBySection.mapValues(asdf)
			return res
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

	open class func groupEventsByPageAndSections<T: JZBaseEvent,
		SectionId: Hashable>(
		originalEvents: [T],
		grouping: KeyPath<T, SectionId>,
		sorting:
		@escaping ((key: SectionId, value: [T]), (key: SectionId, value: [T])) -> Bool)
		-> [Date: [[T]]] {
			let byDate: [Date: [T]] = JZWeekViewHelper.getIntraEventsByDate(originalEvents: originalEvents)
			return groupEventsByPageAndSections(eventsBySection: byDate,
												grouping: grouping,
												sorting: sorting)
	}
}
