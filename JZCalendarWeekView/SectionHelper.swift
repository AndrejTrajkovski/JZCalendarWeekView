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

//	static func calcDateToSectionsMap(events: [Date: [[JZBaseEvent]]], pageDates: [Date]) -> ([Date: [Int]], [Int: Date]) {
//		var runningTotal = 0
//		var result: [Date: [Int]] = [:]
//		var viceVersa: [Int: Date] = [:]
//		for pageDate in pageDates {
//			let dateEvents = events[pageDate]
//			let upper = (dateEvents?.count ?? 1) + runningTotal
//			let sections = Array(runningTotal..<upper)
//			result[pageDate] = sections
//			sections.forEach {
//				viceVersa[$0] = pageDate
//			}
//			runningTotal = upper
//		}
//		return (result, viceVersa)
//	}
//
	
//
//	public func update<T: Hashable, E: JZBaseEvent>(selectedDate: Date,
//									sectionIds: [T],
//									events: [E],
//									sectionKeyPath: AnyHashableKeyPath<E>) {
//		let byDateAndSection = group(events, sectionIds, sectionKeyPath)
//		update(selectedDate,
//			   sectionIds,
//			   byDateAndSection,
//			   sectionKeyPath)
//	}
//
//	public func update<T: Hashable, E: JZBaseEvent>(_ selectedDate: Date,
//									_ sectionIds: [T],
//									_ byDateAndSection: [Date: [[E]]],
//									_ sectionKeyPath: AnyHashableKeyPath<E>) {
//		self.sectionKeyPath = sectionKeyPath
//		self.sectionIds = sectionIds.map(AnyHashable.init)
//		self.allEventsBySubSection = byDateAndSection
//		self.pageDates = [
//			selectedDate,
//			selectedDate.add(component: .day, value: 1),
//			selectedDate.add(component: .day, value: 2)
//		]
//		(dateToSectionsMap, sectionToDateMap) = SectionHelper.calcDateToSectionsMap(events: byDateAndSection, pageDates: self.pageDates)
//	}
//
	
	@available(iOS 13, *)
	public class func group<SectionId: Hashable, Subsection: Identifiable, E: JZBaseEvent>(_ events: [E],
																							 _ subsections: [Subsection],
																							 _ sectionKeyPath: KeyPath<E, SectionId>,
																							 _ subsectionKeyPath: KeyPath<E, Subsection.ID>)
	-> [Date: [SectionId: [Subsection.ID: [E]]]] {
		let byDate = JZWeekViewHelper.getIntraEventsByDate(originalEvents: events)
		return byDate.mapValues {
			let byEmployee = Dictionary.init(grouping: $0, by: { $0[keyPath: sectionKeyPath] })
			let final = byEmployee.mapValues { eventsByDate in
				group(subsections,
					  eventsByDate,
					  subsectionKeyPath)
			}
			return final
		}
	}
	
	@available(iOS 13, *)
	public class func group<T: Identifiable, E: JZBaseEvent>(_ subsections: [T],
															 _ events: [E],
															 _ keyPath: KeyPath<E, T.ID>) -> [T.ID: [E]] {
		let eventsBySection = Dictionary.init(grouping: events, by: { $0[keyPath: keyPath] })
		return subsections.map(\.id).reduce(into: [T.ID: [E]](), { res, sectionId in
			res[sectionId] = eventsBySection[sectionId, default: []]
		})
	}
}
