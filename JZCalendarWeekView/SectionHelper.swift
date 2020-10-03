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
}
