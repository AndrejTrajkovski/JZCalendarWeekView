import Foundation

public enum Page: Int {
	var idx: Int { self.rawValue }
	case previous
	case current
	case next
}

open class SectionWeekView: JZLongPressWeekView {
	open var dataSource: SectionWeekViewDataSource! {
		didSet {
			dataSource.flowLayout = flowLayout
			flowLayout.delegate = dataSource
			collectionView.delegate = dataSource
			collectionView.dataSource = dataSource
		}
	}
	
	override open func setup() {
        flowLayout = SectionsFlowLayout()
        collectionView = JZCollectionView(frame: bounds, collectionViewLayout: flowLayout)
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
		dataSource.update(pageWidth: getSectionWidth())
	}

	/// Was going to use toDecimal1Value as well, but the CGFloat is always got the wrong precision
	/// In order to make sure the width of all sections is the same, add few points to CGFloat
	private func getSectionWidth() -> CGFloat {
		var sectionWidth = contentViewWidth
		let remainder = sectionWidth.truncatingRemainder(dividingBy: 1)
		switch remainder {
		case 0...0.25:
			sectionWidth = sectionWidth.rounded(.down)
		case 0.25...0.75:
			sectionWidth = sectionWidth.rounded(.down) + 0.5
		default:
			sectionWidth = sectionWidth.rounded(.up)
		}
		// Maximum added width for row header should be 0.25 * numberOfRows
		let rowHeaderWidth = frame.width - flowLayout.contentsMargin.left - flowLayout.contentsMargin.right - sectionWidth
		flowLayout.rowHeaderWidth = rowHeaderWidth
		return sectionWidth
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
}

extension JZBaseWeekView {
	public func collectionView(_ collectionView: UICollectionView, layout: JZWeekViewFlowLayout, minMaxXsFor section: Int) -> (SectionMinMaxX) {
		fatalError("only for SectionWeekView subclass")
	}
}
