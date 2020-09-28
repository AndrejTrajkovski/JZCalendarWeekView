import Foundation

//public enum Page: Int {
//	var idx: Int { self.rawValue }
//	case previous
//	case current
//	case next
//}

open class SectionWeekView: JZLongPressWeekView {

	open var dataSource: SectionWeekViewDataSource! {
		didSet {
			dataSource.flowLayout = flowLayout
			flowLayout.delegate = dataSource
			collectionView.dataSource = dataSource
		}
	}

	override open func setup() {
        flowLayout = SectionsFlowLayout()
        collectionView = JZCollectionView(frame: bounds, collectionViewLayout: flowLayout)
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
		dataSource.updateXs(pageWidth: getSectionWidth())
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
		dataSource.update(date: initDate,
						  events: events)
	}

	override open func loadNextOrPrevPage(isNext: Bool) {
		let addValue = isNext ? numOfDays : -numOfDays
		self.initDate = self.initDate.add(component: .day, value: addValue!)
		dataSource.update(date: initDate)
		DispatchQueue.main.async { [unowned self] in
            self.layoutSubviews()
            self.forceReload()
        }
    }
}

extension JZBaseWeekView {
	public func collectionView(_ collectionView: UICollectionView, layout: JZWeekViewFlowLayout, minMaxXsFor section: Int) -> (SectionInfo) {
		fatalError("only for SectionWeekView subclass")
	}
}
