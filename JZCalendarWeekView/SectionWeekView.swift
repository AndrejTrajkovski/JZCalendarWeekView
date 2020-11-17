import Foundation
import UIKit

public protocol SectionLongPressDelegate: class {
	func weekView<SectionId: Hashable, SubsectionId: Hashable>(_ weekView: JZLongPressWeekView, didEndAddNewLongPressAt startDate: Date, pageAndSectionIdx:(Date?, SectionId?, SubsectionId?))

	func weekView<Event: JZBaseEvent, SectionId: Hashable, SubsectionId: Hashable>
	(_ weekView: JZLongPressWeekView,
	 editingEvent: Event,
	 didEndMoveLongPressAt startDate: Date,
	 endPageAndSectionIdx:(Date?, SectionId?, SubsectionId?),
	 startPageAndSectionIdx: (Date?, SectionId?, SubsectionId?))
	
	func weekView<Event: JZBaseEvent, SectionId: Hashable, SubsectionId: Hashable>
	(_ weekView: JZLongPressWeekView,
	 editingEvent: Event,
	 didEndChangeDurationAt endDate: Date,
	 startPageAndSectionIdx: (Date?, SectionId?, SubsectionId?))
}

///Divides the calendar into 3 pages (previous, current, next). One page shows events for one date. Each page can then be sliced into subsections. Works in conjuction with SectionsFlowLayout, SectionsWeekViewDataSource and SectionLongPressDelegate.
@available(iOS 13, *)
open class SectionWeekView<Event: JZBaseEvent, Section: Identifiable & Equatable, Subsection: Identifiable & Equatable, BGTime: JZBackgroundTime>: JZLongPressWeekView {
	public var sectionsDataSource: SectionWeekViewDataSource<Event, Section, Subsection, BGTime>?
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
		let sectionXs = sectionsDataSource?.makeSectionXs(pageWidth: flowLayout.sectionWidth, offset: flowLayout.rowHeaderWidth)
		sectionXs.map(sectionsFlowLayout.updateSectionsXs)
	}

	public func setupCalendar(
		setDate: Date
	) {
		super.setupCalendar(numOfDays: 1,
							setDate: setDate,
							allEvents: [:],
							scrollType: .pageScroll,
							currentTimelineType: .page)
		//FIXME: Maybe delete this call
//		sectionsDataSource?.update(initDate: setDate)
	}

	override open func loadNextOrPrevPage(isNext: Bool) {
		let addValue = isNext ? numOfDays : -numOfDays
		self.initDate = self.initDate.add(component: .day, value: addValue!)
		sectionsDataSource?.update(initDate: self.initDate)
		DispatchQueue.main.async { [unowned self] in
            self.layoutSubviews()
            self.forceReload()
			self.baseDelegate?.userDidFlipPage(self, isNextPage: isNext)
        }
    }
	
	override open func newEventWidth() -> CGFloat {
		sectionsFlowLayout.subsectionWidth
	}
	
	fileprivate func handleEndedState(_ pointInCollectionView: CGPoint, _ longPressViewStartDate: Date, longPressPageAndSubsection: (Date?, Section.ID?, Subsection.ID?)) {
		let startIds = sectionsDataSource?.getDateSectionIdAndSubsectionId(for: currentEditingInfo.indexPath.section) ?? (nil, nil, nil)
		if currentLongPressType == .addNew {
			sectionLongPressDelegate?.weekView(self, didEndAddNewLongPressAt: longPressViewStartDate, pageAndSectionIdx: longPressPageAndSubsection)
		} else if currentLongPressType == .move {
			sectionLongPressDelegate?.weekView(self, editingEvent: currentEditingInfo.event, didEndMoveLongPressAt: longPressViewStartDate, endPageAndSectionIdx: longPressPageAndSubsection, startPageAndSectionIdx: startIds)
		} else if case .changeDuration = currentLongPressType {
			let endHourMinute = getDateForPointY(pointInCollectionView.y)
			let endDate = longPressViewStartDate.set(hour: endHourMinute.0, minute :endHourMinute.1)
			sectionLongPressDelegate?.weekView(self, editingEvent: currentEditingInfo.event, didEndChangeDurationAt: endDate, startPageAndSectionIdx: startIds)
		}
	}
	
	override func handleLongPressGesture(_ gestureRecognizer: UILongPressGestureRecognizer) {

        let pointInSelfView = gestureRecognizer.location(in: self)
        /// Used for get startDate of longPressView
        let pointInCollectionView = gestureRecognizer.location(in: collectionView)

        let state = gestureRecognizer.state
        var currentMovingCell: UICollectionViewCell!

		setupLongPress(pointInCollectionView, &currentMovingCell, gestureRecognizer)

        // The startDate of the longPressView (the date of top Y in longPressView)
        var longPressViewStartDate: Date!
		var longPressPageAndSubsection: (Date?, Section.ID?, Subsection.ID?)
        // pressPosition is nil only when state equals began
        if pressPosition != nil {
            longPressViewStartDate = getLongPressViewStartDate(pointInCollectionView: pointInCollectionView, pointInSelfView: pointInSelfView)
			longPressPageAndSubsection = getPageAndSubsectionIdx(pointInCollectionView.x)
        }

        if state == .began {

			getPressPositionAndInfo(currentMovingCell, pointInCollectionView)
			
            longPressViewStartDate = getLongPressViewStartDate(pointInCollectionView: pointInCollectionView, pointInSelfView: pointInSelfView)
			longPressPageAndSubsection = getPageAndSubsectionIdx(pointInCollectionView.x)
			setupLongPressView(currentMovingCell, longPressViewStartDate, pointInCollectionView, pointInSelfView)
			setupEditingCell(currentMovingCell)
			animateLongPressView()
			
        } else if state == .changed {
			handleLongPressViewFrameInChangedState(pointInSelfView)
		} else if state == .cancelled {

			handleCancelledState()
			longPressDelegate?.weekView(self, longPressType: currentLongPressType, didCancelLongPressAt: longPressViewStartDate)
		} else if state == .ended {

			handleEndedState(pointInCollectionView, longPressViewStartDate, longPressPageAndSubsection: longPressPageAndSubsection)
			self.longPressView.removeFromSuperview()
        }

		cleanUp(state, longPressViewStartDate, pointInSelfView)
    }
	
	override open func getMidSectionXInSelfView(_ xCollectionView: CGFloat) -> CGFloat {
		self.getMidSectionXInCollectionView(xCollectionView).truncatingRemainder(dividingBy: flowLayout.sectionWidth)
	}
	
	override open func getMidSectionXInCollectionView(_ xCollectionView: CGFloat) -> CGFloat {
		sectionsFlowLayout.sectionsXPoints.first(where: {
			$0.value.minX < xCollectionView && xCollectionView <= $0.value.maxX
		})?.value.midX ?? 0
	}

	override public func collectionView(_ collectionView: UICollectionView, layout: JZWeekViewFlowLayout, dayForSection section: Int) -> Date {
		sectionsDataSource!.dayFor(section: section)
	}

	override public func collectionView(_ collectionView: UICollectionView, layout: JZWeekViewFlowLayout, startTimeForItemAtIndexPath indexPath: IndexPath) -> Date {
		return getCurrentEvent(with: indexPath)!.intraStartDate
	}

	override public func collectionView(_ collectionView: UICollectionView, layout: JZWeekViewFlowLayout, endTimeForItemAtIndexPath indexPath: IndexPath) -> Date {
		return getCurrentEvent(with: indexPath)!.intraEndDate
	}
	
	open override func numberOfSections(in collectionView: UICollectionView) -> Int {
		//filter neighbor dates only
		sectionsDataSource?.numberOfSections() ?? 0
	}

	open override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		sectionsDataSource?.numberOfItemsIn(section: section) ?? 0
	}
	
//	public override func collectionView(_ collectionView: UICollectionView, layout: JZWeekViewFlowLayout, startTimeForBackgroundAtSection section: Int) -> Date {
//		
//	}
//	
//	public override func collectionView(_ collectionView: UICollectionView, layout: JZWeekViewFlowLayout, endTimeForBackgroundAtSection section: Int) -> Date {
//		
//	}
	
	@objc open override func getCurrentEvent(with indexPath: IndexPath) -> JZBaseEvent? {
		return sectionsDataSource?.getCurrentEvent(at: indexPath)
	}
}

//MARK:- UICollectionViewDataSource
@available(iOS 13, *)
extension SectionWeekView {
	
	func getSection(_ xCollectionView: CGFloat) -> Int? {
		return sectionsFlowLayout.sectionsXPoints.first(where: {
			$0.value.minX < xCollectionView && $0.value.maxX >= xCollectionView
		})?.key
	}

	func getPageAndSubsectionIdx(_ xCollectionView: CGFloat) -> (Date?, Section.ID?, Subsection.ID?) {
		if let section = getSection(xCollectionView),
		   let dataSource = sectionsDataSource {
			return dataSource.getDateSectionIdAndSubsectionId(for: section)
		} else {
			return (nil, nil, nil)
		}
	}
}

public extension Collection {
	/// Returns the element at the specified index if it is within bounds, otherwise nil.
	subscript (safe index: Index) -> Element? {
		return indices.contains(index) ? self[index] : nil
	}
}
