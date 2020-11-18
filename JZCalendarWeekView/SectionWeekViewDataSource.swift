import Foundation
import CoreGraphics

@available(iOS 13, *)
public class SectionWeekViewDataSource<Event: JZBaseEvent, Section: Identifiable & Equatable, Subsection: Identifiable & Equatable, BGTime: JZBackgroundTime> {
	
	public init() {}
	
	private var pageDates: [Date] = []
	public var sections: [Section] = []
	public var subsections: [Section.ID: [Subsection]] = [:]
	public var backgroundTimes: [Date: [Section.ID: [Subsection.ID: [BGTime]]]] = [:]
	public var allEventsBySection: [Date: [Section.ID: [Subsection.ID: [Event]]]] = [:]
	private var dateToSectionsMap: [Date: [Int]] = [:]
	private var sectionToIdsMap: [Int: (Date, Section.ID, Subsection.ID)] = [:]

	public func update(initDate: Date) {
		update(initDate,
			   sections,
			   subsections,
			   allEventsBySection,
			   backgroundTimes)
	}
	
	public func update(_ selectedDate: Date,
					   _ sections: [Section],
					   _ subsections: [Section.ID: [Subsection]],
					   _ byDateAndSection: [Date: [Section.ID: [Subsection.ID: [Event]]]],
					   _ bgTimes: [Date: [Section.ID: [Subsection.ID: [BGTime]]]]) {
		self.sections = sections
		self.subsections = subsections
		self.allEventsBySection = byDateAndSection
		self.backgroundTimes = bgTimes
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
					   offset: CGFloat,
					   minRowWidth: CGFloat) -> [Int: SectionXs]{
		var pageSectionXx: [Int: SectionXs] = [:]
		var minX: CGFloat = offset
		let sections = dateToSectionsMap.sorted(by: { $0.key < $1.key}).flatMap({ $0.value })
		for section in sections {
			let pageDict = dateToSectionsMap.first(where: { $0.value.contains(section)})!
			var width = (pageWidth / CGFloat(pageDict.value.count))
			if width < minRowWidth { width = minRowWidth }
			let maxX = minX + width
			pageSectionXx[section] = SectionXs(minX: minX, maxX: maxX)
			minX = maxX
		}
		return pageSectionXx
	}
}

@available(iOS 13, *)
extension SectionWeekViewDataSource {

	public func backgroundTimes(section: Int) -> [JZBackgroundTime] {
		let (dateOpt, sectionIdOpt, subsectionIdOpt) = self.getDateSectionIdAndSubsectionId(for: section)
		guard let date = dateOpt,
			  let sectionId = sectionIdOpt,
			  let subsectionId = subsectionIdOpt else {
			return []
		}
		return backgroundTimes[date]?[sectionId]?[subsectionId] ?? []
	}
	
	func numberOfSections() -> Int {
		sections.count * 3
	}

	func numberOfItemsIn(section: Int) -> Int {
		getEvents(at: section).count
	}

	func dayFor(section: Int) -> Date {
		sectionToIdsMap[section]!.0
	}

	func makeSectionXs(pageWidth: CGFloat, offset: CGFloat, minRowWidth: CGFloat) -> [Int: SectionXs] {
		return calcSectionXs(dateToSectionsMap, pageWidth: pageWidth, offset: offset, minRowWidth: minRowWidth)
	}

	public func getDateSectionIdAndSubsectionId(for section: Int) -> (Date?, Section.ID?, Subsection.ID?) {
		return sectionToIdsMap[section] ?? (nil, nil, nil)
	}

	func getEvents(at section: Int) -> [Event] {
		let (optDate, optSectionId, optSubsectionId) = sectionToIdsMap[section] ?? (nil, nil, nil)
		guard let date = optDate, let sectionId = optSectionId, let subsectionId = optSubsectionId else { return [] }
		return allEventsBySection[date]?[sectionId]?[subsectionId] ?? []
	}

	func getCurrentEvent(at indexPath: IndexPath) -> Event? {
		return getEvents(at: indexPath.section)[safe: indexPath.item]
	}
	
	public func sectionAndSubsection(for section: Int) -> (Section?, Subsection?) {
		let (_, sectionIdOpt, subsectionId) = self.getDateSectionIdAndSubsectionId(for: section)
		guard let sectionId = sectionIdOpt else { return (nil, nil) }
		let section = sections.first(where: { $0.id == sectionId })
		let subsection = subsections[sectionId]?.first(where: { $0.id == subsectionId })
		return (section, subsection)
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
			pageDatesResult[pageDate] = []
			for sectionIdx in 0..<sections.count {
				let section = sections[sectionIdx]
				if let subsectionsForSection = subsections[section.id],
				   subsectionsForSection.count > 0 {
					let upper = subsectionsForSection.count + runningTotal
					let subsectionsIdxs = Array(runningTotal..<upper)
					pageDatesResult[pageDate]!.append(contentsOf: subsectionsIdxs)
					subsectionsIdxs.enumerated().forEach { idx, element in
						result[element] = (pageDate, section.id, subsectionsForSection[idx].id)
					}
					runningTotal = upper
				}
			}
		}
		return (pageDatesResult, result)
	}
}
