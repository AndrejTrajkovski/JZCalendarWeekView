import Foundation

open class SectionWeekViewDataSource: NSObject, SectionWeekViewFlowLayoutDelegate, UICollectionViewDelegate, UICollectionViewDataSource {

	weak var flowLayout: JZWeekViewFlowLayout!
	private var pageDates: [Date] = []
	private var allEventsBySubSection: [Date: [[JZBaseEvent]]] = [:]
	private var dateToSectionsMap: [Date: [Int]] = [:]
	private var sectionsInfo: [Int: SectionInfo] = [:]
	public func updateXs(pageWidth: CGFloat) {
		self.sectionsInfo = Self.calcPageSectionXs(self.dateToSectionsMap,
												 pageWidth: pageWidth)
	}

	public func update(date: Date? = nil,
					   events: [Date: [[JZBaseEvent]]]? = nil) {
		if events != nil {
			self.allEventsBySubSection = events!
		}
		if date != nil {
			self.pageDates = [
				date!,
				date!.add(component: .day, value: 1),
				date!.add(component: .day, value: 2)
			]
		}
		self.dateToSectionsMap = Self.calcDateToSectionsMap(events: self.allEventsBySubSection, pageDates: self.pageDates)
	}

	public func collectionView(_ collectionView: UICollectionView,
							   layout: JZWeekViewFlowLayout,
							   minMaxXsFor section: Int) -> SectionInfo {
		return sectionsInfo[section]!
	}

	open func getDateForSection(_ section: Int) -> Date {
		return sectionsInfo[section]!.date
	}

	public func collectionView(_ collectionView: UICollectionView, layout: JZWeekViewFlowLayout, dayForSection section: Int) -> Date {
		return getDateForSection(section)
	}

	public func collectionView(_ collectionView: UICollectionView, layout: JZWeekViewFlowLayout, startTimeForItemAtIndexPath indexPath: IndexPath) -> Date {
		let date = flowLayout.dateForColumnHeader(at: indexPath)
		if let eventsByDate = allEventsBySubSection[date] {
			let (_, withinPageIdx) = getPageAndWithinPageIndex(indexPath.section)!
			let withinPageEvents = eventsByDate[withinPageIdx]
			return withinPageEvents[indexPath.item].intraStartDate
		} else {
			fatalError("Cannot get events")
		}
	}

	public func collectionView(_ collectionView: UICollectionView, layout: JZWeekViewFlowLayout, endTimeForItemAtIndexPath indexPath: IndexPath) -> Date {
		let date = flowLayout.dateForColumnHeader(at: indexPath)
		if let eventsByDate = allEventsBySubSection[date] {
			let (_, withinPageIdx) = getPageAndWithinPageIndex(indexPath.section)!
			let withinPageEvents = eventsByDate[withinPageIdx]
			return withinPageEvents[indexPath.item].intraEndDate
		} else {
			fatalError("Cannot get events")
		}
	}

    // TODO: Only used when multiple cell types are used and need different overlap rules => layoutItemsAttributes
    public func collectionView(_ collectionView: UICollectionView, layout: JZWeekViewFlowLayout, cellTypeForItemAtIndexPath indexPath: IndexPath) -> String {
        return JZSupplementaryViewKinds.eventCell
    }

	func getPageAndWithinPageIndex(_ section: Int) -> (Int, Int)? {
		let sectionDate = sectionsInfo[section]!.date
		let dateSections = dateToSectionsMap[sectionDate]!
		let pageSectionIdx = dateSections.firstIndex(of: section)
		return pageSectionIdx.map {
			(pageDates.firstIndex(of: sectionDate)!, $0)
		}
	}

	func currentPageSectionWidth() -> CGFloat {
		let middlePageDate = pageDates[1]
		let middleSectionsIdxs = dateToSectionsMap[middlePageDate]!
		return sectionsInfo[middleSectionsIdxs.first!]!.width
	}

	static func calcPageSectionXs(_ dateToSectionsMap: [Date: [Int]],
								  pageWidth: CGFloat) -> [Int: SectionInfo] {
		var pageSectionXx: [Int: SectionInfo] = [:]
		var minX: CGFloat = 42 //TODO: pass in rowWidth from flowlayout
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

	open func getCurrentEvent(with indexPath: IndexPath) -> JZBaseEvent? {
		let date = flowLayout.dateForColumnHeader(at: indexPath)
		let appointments = allEventsBySubSection[date]
		guard let (_, withinPageIdx) = getPageAndWithinPageIndex(indexPath.section) else { return nil }
		let employeeEvents = appointments?[withinPageIdx]
		return employeeEvents?[indexPath.item]
	}
}

//MARK:- UICollectionViewDataSource
extension SectionWeekViewDataSource {

	open func numberOfSections(in collectionView: UICollectionView) -> Int {
		//filter neighbor dates only
		return dateToSectionsMap.reduce(into: 0, { $0 += $1.value.count })
	}

	open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		let date = flowLayout.dateForColumnHeader(at: IndexPath(item: 0, section: section))
		if let eventsByDate = allEventsBySubSection[date] {
			let (_, withinPageIdx) = getPageAndWithinPageIndex(section)!
			return eventsByDate[withinPageIdx].count
		} else {
			return 0
		}
	}

	open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		fatalError("override in subclass")
	}
	
	open func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
		var view = UICollectionReusableView()
		
		switch kind {
		case JZSupplementaryViewKinds.columnHeader:
			if let columnHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: kind, for: indexPath) as? JZColumnHeader {
				columnHeader.updateView(date: flowLayout.dateForColumnHeader(at: indexPath))
				view = columnHeader
			}
		case JZSupplementaryViewKinds.rowHeader:
			if let rowHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: kind, for: indexPath) as? JZRowHeader {
				rowHeader.updateView(date: flowLayout.timeForRowHeader(at: indexPath))
				view = rowHeader
			}
		case JZSupplementaryViewKinds.cornerHeader:
			if let cornerHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: kind, for: indexPath) as? JZCornerHeader {
				view = cornerHeader
			}
		case JZSupplementaryViewKinds.allDayHeader:
			if let alldayHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: kind, for: indexPath) as? JZAllDayHeader {
				alldayHeader.updateView(views: [])
				view = alldayHeader
			}
		case JZSupplementaryViewKinds.currentTimeline:
//			if currentTimelineType == .page {
				if let currentTimeline = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: kind, for: indexPath) as? JZCurrentTimelinePage {
					view = getPageTypeCurrentTimeline(timeline: currentTimeline, indexPath: indexPath)
				}
//			} else {
//				if let currentTimeline = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: kind, for: indexPath) as? JZCurrentTimelineSection {
//					view = getSectionTypeCurrentTimeline(timeline: currentTimeline, indexPath: indexPath)
//				}
//			}
		default: break
		}
		return view
	}
	
	open func getPageTypeCurrentTimeline(timeline: JZCurrentTimelinePage, indexPath: IndexPath) -> UICollectionReusableView {
        let date = flowLayout.dateForColumnHeader(at: indexPath)
        let daysToToday = Date.daysBetween(start: date, end: Date(), ignoreHours: true)
        timeline.isHidden = abs(daysToToday) > 0
        timeline.updateView(needShowBallView: daysToToday == 0)
        return timeline
    }
}
