import Foundation
import CoreGraphics

@available(iOS 13, *)
public class SectionWeekViewDataSource<Event: JZBaseEvent, Section: Identifiable & Equatable,Subsection: Identifiable & Equatable> {
	
	public init() {}
	
	private var pageDates: [Date] = []
	public var sections: [Section] = []
	public var subsections: [Section.ID: [Subsection]] = [:]
	public var allEventsBySection: [Date: [Section.ID: [Subsection.ID: [Event]]]] = [:]
	private var dateToSectionsMap: [Date: [Int]] = [:]
	private var sectionToIdsMap: [Int: (Date, Section.ID, Subsection.ID)] = [:]

	public func update(initDate: Date) {
		update(initDate,
			   sections,
			   subsections,
			   allEventsBySection)
	}
	
	public func update(_ selectedDate: Date,
					   _ sections: [Section],
					   _ subsections: [Section.ID: [Subsection]],
					   _ byDateAndSection: [Date: [Section.ID: [Subsection.ID: [Event]]]]) {
		self.sections = sections
		self.subsections = subsections
		self.allEventsBySection = byDateAndSection
		self.pageDates = [
			selectedDate,
			selectedDate.add(component: .day, value: 1),
			selectedDate.add(component: .day, value: 2)
		]
		(dateToSectionsMap, sectionToIdsMap) = calcSectionToIdsMap(sections: sections,
																   subsections: subsections,
																   pageDates: self.pageDates)
	}

	func calcSectionXs(_ dateToSectionsMap: [Date: [Int]],
								  pageWidth: CGFloat,
								  offset: CGFloat) -> [Int: SectionXs]{
		var pageSectionXx: [Int: SectionXs] = [:]
		var minX: CGFloat = offset
		let sections = dateToSectionsMap.sorted(by: { $0.key < $1.key}).flatMap({ $0.value })
		for section in sections {
			let pageDict = dateToSectionsMap.first(where: { $0.value.contains(section)})!
			let width = (pageWidth / CGFloat(pageDict.value.count))
			let maxX = minX + width
			pageSectionXx[section] = SectionXs(minX: minX, maxX: maxX)
			minX = maxX
		}
		return pageSectionXx
	}
}

@available(iOS 13, *)
extension SectionWeekViewDataSource {

	func numberOfSections() -> Int {
		sections.count * 3
	}

	func numberOfItemsIn(section: Int) -> Int {
		getEvents(at: section).count
	}

	func dayFor(section: Int) -> Date {
		sectionToIdsMap[section]!.0
	}

	func makeSectionXs(pageWidth: CGFloat, offset: CGFloat) -> [Int: SectionXs] {
		return calcSectionXs(dateToSectionsMap, pageWidth: pageWidth, offset: offset)
	}

	func getDateSectionIdAndSubsectionId(for section: Int) -> (Date?, Section.ID?, Subsection.ID?) {
		return sectionToIdsMap[section] ?? (nil, nil, nil)
//		guard let sectionDate = sectionToDateMap[section] else {
//			return (nil, nil, nil)
//		}
//		guard let dateSections = dateToSectionsMap[sectionDate],
//			  let sectionIdx = dateSections.firstIndex(of: section) else {
//			return (sectionDate, nil, nil)
//		}
//		let sectionId = sections[sectionIdx].id
//		let idx = sections.firstIndex(where: { $0.id == sectionId })
	}

	func getEvents(at section: Int) -> [Event] {
		let (optDate, optSectionId, optSubsectionId) = sectionToIdsMap[section] ?? (nil, nil, nil)
		guard let date = optDate, let sectionId = optSectionId, let subsectionId = optSubsectionId else { return [] }
		return allEventsBySection[date]?[sectionId]?[subsectionId] ?? []
	}

	func getCurrentEvent(at indexPath: IndexPath) -> Event? {
		return getEvents(at: indexPath.section)[safe: indexPath.item]
	}
	
	public func section(for section: Int) -> Section {
		sections[section % 3]
	}
}

extension SectionWeekViewDataSource {
	public func calcSectionToIdsMap(sections: [Section],
									subsections: [Section.ID: [Subsection]],
									pageDates: [Date]) -> ([Date: [Int]], [Int: (Date, Section.ID, Subsection.ID)]) {
		var runningTotal = 0
		var result: [Int: (Date, Section.ID, Subsection.ID)] = [:]
		var pageDatesResult: [Date: [Int]] = [:]
		for dateIdx in 0..<pageDates.count {
			let pageDate = pageDates[dateIdx]
			for sectionIdx in 0..<sections.count {
				let section = sections[sectionIdx]
				let subsectionsForSection = subsections[section.id] ?? []
//				for subsectionIdx in 0..<(subsections.count ?? 0) {
					let upper = subsections.count + runningTotal
					let sectionsIdxs = Array(runningTotal..<upper)
					pageDatesResult[pageDate] = sectionsIdxs
					sectionsIdxs.enumerated().forEach { idx, element in
						result[element] = (pageDate, section.id, subsectionsForSection[idx].id)
					}
					runningTotal = upper
//				}
			}
		}
		return (pageDatesResult, result)
//		var viceVersa: [Int: (Date, Section.ID, Subsection.ID)] = [:]
//		for pageDate in pageDates {
//			let resss: [[Subsection]] = sections.compactMap { (section: Section) in
//				let values = subsections[section.id]
//				return values
//			}
//			let upper = subsections.values.count + runningTotal
//			let sections = Array(runningTotal..<upper)
//			result[pageDate] = sections
//			sections.forEach {
//				viceVersa[$0] = pageDate
//			}
//			runningTotal = upper
//		}
	}
}
