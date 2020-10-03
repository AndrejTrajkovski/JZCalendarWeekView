import Foundation
import UIKit

public protocol SectionLongPressDelegate: class {
	func weekView(_ weekView: JZLongPressWeekView, didEndAddNewLongPressAt startDate: Date, pageAndSectionIdx:(Int, Int))

	func weekView(_ weekView: JZLongPressWeekView, editingEvent: JZBaseEvent, didEndMoveLongPressAt startDate: Date, pageAndSectionIdx:(Int, Int))
}

///Divides the calendar into 3 pages (previous, current, next). One page shows events for one date. Each page can then be sliced into subsections. Works in conjuction with SectionsFlowLayout, SectionsWeekViewDataSource and SectionLongPressDelegate.
open class SectionWeekView: JZLongPressWeekView {
	public var sectionsFlowLayout: SectionsFlowLayout!
	public override var flowLayout: JZWeekViewFlowLayout! {
		get {
			return sectionsFlowLayout
		}
		set {
			if let newSectionsFlowLayout = newValue as? SectionsFlowLayout {
				sectionsFlowLayout = newSectionsFlowLayout
			} else {
				fatalError("should work with SectionsFlowLayout")
			}
		}
	}
	public weak var sectionLongPressDelegate: SectionLongPressDelegate?
	private var pageDates: [Date] = []
	private var allEventsBySubSection: [Date: [[JZBaseEvent]]] = [:]
	private var dateToSectionsMap: [Date: [Int]] = [:]
	private var sectionToDateMap: [Int: Date] = [:]

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
		(dateToSectionsMap, sectionToDateMap) = SectionHelper.calcDateToSectionsMap(events: self.allEventsBySubSection, pageDates: self.pageDates)
	}

	//must be 1 per page
	public override var numOfDays: Int! {
		get { 1 } set { }
	}

	override open func setup() {
        flowLayout = SectionsFlowLayout()
        collectionView = JZCollectionView(frame: bounds, collectionViewLayout: flowLayout)
		sectionsFlowLayout.delegate = self
		collectionView.dataSource = self
		collectionView.delegate = self
        collectionView.isDirectionalLockEnabled = true
        collectionView.bounces = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = UIColor.white
        addSubview(collectionView)
        collectionView.setAnchorConstraintsFullSizeTo(view: self)

        registerViewClasses()
    }

	open override func layoutSubviews() {
		super.layoutSubviews()
		sectionsFlowLayout.updateSectionsXs(dateToSectionsMap)
	}

	public func setupCalendar(
		setDate: Date,
		events: [Date: [[JZBaseEvent]]],
		visibleTime: Date = Date()
	) {
		super.setupCalendar(numOfDays: 1,
							setDate: setDate,
							allEvents: [:],
							scrollType: .pageScroll,
							currentTimelineType: .page,
							visibleTime: visibleTime)
		update(date: initDate,
						  events: events)
	}

	public func forceSectionReload(reloadEvents: [Date : [[JZBaseEvent]]]) {
		update(events: reloadEvents)
		self.forceReload()
	}

	override open func loadNextOrPrevPage(isNext: Bool) {
		let addValue = isNext ? numOfDays : -numOfDays
		self.initDate = self.initDate.add(component: .day, value: addValue!)
		update(date: initDate)
		DispatchQueue.main.async { [unowned self] in
            self.layoutSubviews()
            self.forceReload()
        }
    }

	//what is section index in the context of JZBaseWeekView, is a page in SectionWeekView
	override open func getDateForSection(_ section: Int) -> Date {
		return pageDates[section]
	}

//	override open func getDateForPointX(_ xCollectionView: CGFloat) -> Date {
//		return sectionToDateMap[getSection(xCollectionView)!]!
//    }

	override func handleLongPressGesture(_ gestureRecognizer: UILongPressGestureRecognizer) {

        let pointInSelfView = gestureRecognizer.location(in: self)
        /// Used for get startDate of longPressView
        let pointInCollectionView = gestureRecognizer.location(in: collectionView)

        let state = gestureRecognizer.state
        var currentMovingCell: UICollectionViewCell!

        if isLongPressing == false {
            if let indexPath = collectionView.indexPathForItem(at: pointInCollectionView) {
                // Can add some conditions for allowing only few types of cells can be moved
                currentLongPressType = .move
                currentMovingCell = collectionView.cellForItem(at: indexPath)
            } else {
                currentLongPressType = .addNew
            }
            isLongPressing = true
        }

        // The startDate of the longPressView (the date of top Y in longPressView)
        var longPressViewStartDate: Date!
		var longPressPageAndSubsection: (Int, Int)!
        // pressPosition is nil only when state equals began
        if pressPosition != nil {
            longPressViewStartDate = getLongPressViewStartDate(pointInCollectionView: pointInCollectionView, pointInSelfView: pointInSelfView)
			longPressPageAndSubsection = getPageAndSubsectionIdx(pointInCollectionView.x)
        }

        if state == .began {

            currentEditingInfo.cellSize = currentLongPressType == .move ? currentMovingCell.frame.size : CGSize(width: flowLayout.sectionWidth, height: flowLayout.hourHeight * CGFloat(addNewDurationMins)/60)
            pressPosition = currentLongPressType == .move ? (pointInCollectionView.x - currentMovingCell.frame.origin.x, pointInCollectionView.y - currentMovingCell.frame.origin.y) :
                                                            (currentEditingInfo.cellSize.width/2, currentEditingInfo.cellSize.height/2)
            longPressViewStartDate = getLongPressViewStartDate(pointInCollectionView: pointInCollectionView, pointInSelfView: pointInSelfView)
			longPressPageAndSubsection = getPageAndSubsectionIdx(pointInCollectionView.x)
            longPressView = initLongPressView(selectedCell: currentMovingCell, type: currentLongPressType, startDate: longPressViewStartDate)
            longPressView.frame.size = currentEditingInfo.cellSize
            longPressView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            self.addSubview(longPressView)

            longPressView.center = CGPoint(x: pointInSelfView.x - pressPosition!.xToViewLeft + currentEditingInfo.cellSize.width/2,
                                           y: pointInSelfView.y - pressPosition!.yToViewTop + currentEditingInfo.cellSize.height/2)
            if currentLongPressType == .move {
                currentEditingInfo.event = (currentMovingCell as! JZLongPressEventCell).event
                getCurrentMovingCells().forEach {
                    $0.contentView.layer.opacity = movingCellOpacity
                    currentEditingInfo.allOpacityContentViews.append($0.contentView)
                }
            }

            UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 5, options: .curveEaseOut,
                           animations: { self.longPressView.transform = CGAffineTransform.identity }, completion: nil)

        } else if state == .changed {
            let topYPoint = max(pointInSelfView.y - pressPosition!.yToViewTop, longPressTopMarginY)
            longPressView.center = CGPoint(x: pointInSelfView.x - pressPosition!.xToViewLeft + currentEditingInfo.cellSize.width/2,
                                           y: topYPoint + currentEditingInfo.cellSize.height/2)

        } else if state == .cancelled {

            UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseOut, animations: {
                self.longPressView.alpha = 0
            }, completion: { _ in
                self.longPressView.removeFromSuperview()
            })
            longPressDelegate?.weekView(self, longPressType: currentLongPressType, didCancelLongPressAt: longPressViewStartDate)

        } else if state == .ended {

            self.longPressView.removeFromSuperview()
            if currentLongPressType == .addNew {
//                longPressDelegate?.weekView(self, didEndAddNewLongPressAt: longPressViewStartDate)
				sectionLongPressDelegate?.weekView(self, didEndAddNewLongPressAt: longPressViewStartDate, pageAndSectionIdx: longPressPageAndSubsection)
            } else if currentLongPressType == .move {
//                longPressDelegate?.weekView(self, editingEvent: currentEditingInfo.event, didEndMoveLongPressAt: longPressViewStartDate)
				sectionLongPressDelegate?.weekView(self, editingEvent: currentEditingInfo.event, didEndMoveLongPressAt: longPressViewStartDate, pageAndSectionIdx: longPressPageAndSubsection)
            }
        }

        if state == .began || state == .changed {
            updateTimeLabel(time: longPressViewStartDate, pointInSelfView: pointInSelfView)
            updateScroll(pointInSelfView: pointInSelfView)
        }

        if state == .ended || state == .cancelled {
            longPressTimeLabel.removeFromSuperview()
            isLongPressing = false
            pressPosition = nil

            if currentLongPressType == .move {
                currentEditingInfo.allOpacityContentViews.forEach { $0.layer.opacity = 1 }
                currentEditingInfo.allOpacityContentViews.removeAll()
            }
            return
        }
    }

	override public func collectionView(_ collectionView: UICollectionView, layout: JZWeekViewFlowLayout, dayForSection section: Int) -> Date {
		return sectionToDateMap[section]!
	}

	override public func collectionView(_ collectionView: UICollectionView, layout: JZWeekViewFlowLayout, startTimeForItemAtIndexPath indexPath: IndexPath) -> Date {
		let date = sectionToDateMap[indexPath.section]!
		if let eventsByDate = allEventsBySubSection[date] {
			let (_, withinPageIdx) = getPageAndWithinPageIndex(indexPath.section)!
			let withinPageEvents = eventsByDate[withinPageIdx]
			return withinPageEvents[indexPath.item].intraStartDate
		} else {
			fatalError("Cannot get events")
		}
	}

	override public func collectionView(_ collectionView: UICollectionView, layout: JZWeekViewFlowLayout, endTimeForItemAtIndexPath indexPath: IndexPath) -> Date {
		let date = sectionToDateMap[indexPath.section]!
		if let eventsByDate = allEventsBySubSection[date] {
			let (_, withinPageIdx) = getPageAndWithinPageIndex(indexPath.section)!
			let withinPageEvents = eventsByDate[withinPageIdx]
			return withinPageEvents[indexPath.item].intraEndDate
		} else {
			fatalError("Cannot get events")
		}
	}

	func getPageAndWithinPageIndex(_ section: Int) -> (Int, Int)? {
		let sectionDate = sectionToDateMap[section]!
		let dateSections = dateToSectionsMap[sectionDate]!
		let pageSectionIdx = dateSections.firstIndex(of: section)
		return pageSectionIdx.map {
			(pageDates.firstIndex(of: sectionDate)!, $0)
		}
	}

	@objc open override func getCurrentEvent(with indexPath: IndexPath) -> JZBaseEvent? {
		let date = sectionToDateMap[indexPath.section]!
		let appointments = allEventsBySubSection[date]
		guard let (_, withinPageIdx) = getPageAndWithinPageIndex(indexPath.section) else { return nil }
		let employeeEvents = appointments?[withinPageIdx]
		return employeeEvents?[indexPath.item]
	}
}

//MARK:- UICollectionViewDataSource
extension SectionWeekView {

	open override func numberOfSections(in collectionView: UICollectionView) -> Int {
		//filter neighbor dates only
		return dateToSectionsMap.reduce(into: 0, { $0 += $1.value.count })
	}

	open override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		let (pageIdx, withinPageIdx) = getPageAndWithinPageIndex(section)!
		let date = pageDates[pageIdx]
		if let eventsByDate = allEventsBySubSection[date] {
			return eventsByDate[withinPageIdx].count
		} else {
			return 0
		}
	}
	
	func getSection(_ xCollectionView: CGFloat) -> Int? {
		return sectionsFlowLayout.sectionsXPoints.first(where: {
			$0.value.minX < xCollectionView && $0.value.maxX >= xCollectionView
		})?.key
	}

	func getPageAndSubsectionIdx(_ xCollectionView: CGFloat) -> (Int, Int)? {
		return getSection(xCollectionView)
			.flatMap(self.getPageAndWithinPageIndex)
	}
}
