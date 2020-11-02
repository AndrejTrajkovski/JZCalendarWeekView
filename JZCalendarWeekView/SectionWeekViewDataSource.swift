import Foundation
import CoreGraphics

public class SectionWeekViewDataSource<Event: JZBaseEvent, SectionId: Hashable> {
	
	public init() {}
	
	private var pageDates: [Date] = []
	public var sectionIds: [SectionId] = []
	public var allEventsBySection: [Date: [SectionId: [Event]]] = [:]
	private var dateToSectionsMap: [Date: [Int]] = [:]
	private var sectionToDateMap: [Int: Date] = [:]
	
	public func calcDateToSectionsMap(sectionIds: [SectionId], pageDates: [Date]) -> ([Date: [Int]], [Int: Date]) {
		var runningTotal = 0
		var result: [Date: [Int]] = [:]
		var viceVersa: [Int: Date] = [:]
		for pageDate in pageDates {
			let upper = sectionIds.count + runningTotal
			let sections = Array(runningTotal..<upper)
			result[pageDate] = sections
			sections.forEach {
				viceVersa[$0] = pageDate
			}
			runningTotal = upper
		}
		return (result, viceVersa)
	}

	public func update(_ selectedDate: Date,
					   _ sectionIds: [SectionId],
					   _ byDateAndSection: [Date: [SectionId: [Event]]]) {
		
		self.sectionIds = sectionIds
		self.allEventsBySection = byDateAndSection
		self.pageDates = [
			selectedDate,
			selectedDate.add(component: .day, value: 1),
			selectedDate.add(component: .day, value: 2)
		]
		(dateToSectionsMap, sectionToDateMap) = calcDateToSectionsMap(sectionIds: sectionIds,
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

extension SectionWeekViewDataSource {

	func numberOfSections() -> Int {
		sectionIds.count * 3
	}

	func numberOfItemsIn(section: Int) -> Int {
		getEvents(at: section).count
	}

	func dayFor(section: Int) -> Date {
		sectionToDateMap[section]!
	}

	func makeSectionXs(pageWidth: CGFloat, offset: CGFloat) -> [Int: SectionXs] {
		return calcSectionXs(dateToSectionsMap, pageWidth: pageWidth, offset: offset)
	}

	public func getPageAndWithinPageIndex(_ section: Int) -> (Int?, Int?) {
		guard let sectionDate = sectionToDateMap[section] else {
			return (nil, nil)
		}
		guard let dateSections = dateToSectionsMap[sectionDate],
			  let pageSectionIdx = dateSections.firstIndex(of: section) else {
			return (pageDates.firstIndex(of: sectionDate)!, nil)
		}
		return (pageDates.firstIndex(of: sectionDate)!, pageSectionIdx)
	}

	func getDateAndSectionId(for section: Int) -> (Date?, SectionId?) {
		guard let sectionDate = sectionToDateMap[section] else {
			return (nil, nil)
		}
		guard let dateSections = dateToSectionsMap[sectionDate],
			  let pageSectionIdx = dateSections.firstIndex(of: section) else {
			return (sectionDate, nil)
		}
		return (sectionDate, sectionIds[pageSectionIdx])
	}

	func getEvents(at section: Int) -> [Event] {
		let(optDate, optSectionId) = getDateAndSectionId(for: section)
		guard let date = optDate, let sectionId = optSectionId else { return [] }
		return allEventsBySection[date]?[sectionId] ?? []
	}

	func getCurrentEvent(at indexPath: IndexPath) -> Event? {
		return getEvents(at: indexPath.section)[safe: indexPath.item]
	}

	public func update(initDate: Date) {
		update(initDate,
			   sectionIds,
			   allEventsBySection)
	}
}
