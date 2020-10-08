import UIKit

open class SectionsFlowLayout: JZWeekViewFlowLayout {

	var sectionsXPoints: [Int: SectionXs] = [:]
	public override var collectionViewContentSize: CGSize {
		        return CGSize(width: rowHeaderWidth + sectionWidth * 3,
                      height: maxSectionHeight)
	}

	func updateSectionsXs(_ dateToSectionsMap: [Date: [Int]]) {
		//in SectionsFlowLayout context sectionWidth is per page width
		//sectionWidth is set before this call in layoutSubviews of JZBaseWeekView
		sectionsXPoints = calcSectionXs(dateToSectionsMap,
										pageWidth: sectionWidth,
										offset: rowHeaderWidth)
	}
	
	override open func prepareHorizontalTileSectionLayoutForSections(_ sectionIndexes: NSIndexSet) {
		guard let collectionView = collectionView, collectionView.numberOfSections != 0 else { return }

		var attributes =  UICollectionViewLayoutAttributes()

		let sectionHeight = (hourHeight * 24).toDecimal1Value()
		let calendarGridMinY = columnHeaderHeight + contentsMargin.top + allDayHeaderHeight
		let calendarContentMinX = rowHeaderWidth + contentsMargin.left
		let calendarContentMinY = columnHeaderHeight + contentsMargin.top + allDayHeaderHeight
		// Current time line
		// TODO: Should improve this method, otherwise every column will display a timeline view
		sectionIndexes.enumerate(_:) { (section, _) in
			let sectionMinMaxXs = sectionsXPoints[section]!
			let sectionMinX = sectionMinMaxXs.minX
			let sectionWidth = sectionMinMaxXs.width
			let timeY = calendarContentMinY + (CGFloat(currentTimeComponents.hour!).toDecimal1Value() * hourHeight
				+ CGFloat(currentTimeComponents.minute!) * minuteHeight)
			let currentTimeHorizontalGridlineMinY = timeY - (defaultGridThickness / 2.0).toDecimal1Value() - defaultCurrentTimeLineHeight/2
			(attributes, currentTimeLineAttributes) = layoutAttributesForSupplemantaryView(at: IndexPath(item: 0, section: section),
																						   ofKind: JZSupplementaryViewKinds.currentTimeline,
																						   withItemCache: currentTimeLineAttributes)
			attributes.frame = CGRect(x: sectionMinX, y: currentTimeHorizontalGridlineMinY, width: sectionWidth, height: defaultCurrentTimeLineHeight)
			attributes.zIndex = zIndexForElementKind(JZSupplementaryViewKinds.currentTimeline)
		}

		// Corner Header
		(attributes, cornerHeaderAttributes) = layoutAttributesForSupplemantaryView(at: IndexPath(item: 0, section: 0),
																					ofKind: JZSupplementaryViewKinds.cornerHeader,
																					withItemCache: cornerHeaderAttributes)
		attributes.frame = CGRect(origin: collectionView.contentOffset, size: CGSize(width: rowHeaderWidth, height: columnHeaderHeight))
		attributes.zIndex = zIndexForElementKind(JZSupplementaryViewKinds.cornerHeader)
	
		// Row header
		let rowHeaderMinX = fmax(collectionView.contentOffset.x, 0)
	
		for rowHeaderIndex in 0...24 {
			(attributes, rowHeaderAttributes) = layoutAttributesForSupplemantaryView(at: IndexPath(item: rowHeaderIndex, section: 0),
																					 ofKind: JZSupplementaryViewKinds.rowHeader,
																					 withItemCache: rowHeaderAttributes)
			let rowHeaderMinY = calendarContentMinY + hourHeight * CGFloat(rowHeaderIndex) - (hourHeight / 2.0).toDecimal1Value()
			attributes.frame = CGRect(x: rowHeaderMinX, y: rowHeaderMinY, width: rowHeaderWidth, height: hourHeight)
			attributes.zIndex = zIndexForElementKind(JZSupplementaryViewKinds.rowHeader)
		}
		
		// Row Header Background
		(attributes, rowHeaderBackgroundAttributes) = layoutAttributesForDecorationView(at: IndexPath(item: 0, section: 0),
																						ofKind: JZDecorationViewKinds.rowHeaderBackground,
																						withItemCache: rowHeaderBackgroundAttributes)
		attributes.frame = CGRect(x: rowHeaderMinX, y: collectionView.contentOffset.y, width: rowHeaderWidth, height: collectionView.frame.height)
		attributes.zIndex = zIndexForElementKind(JZDecorationViewKinds.rowHeaderBackground)
		
		
		// column header background
		(attributes, columnHeaderBackgroundAttributes) = layoutAttributesForDecorationView(at: IndexPath(item: 0, section: 0),
																						   ofKind: JZDecorationViewKinds.columnHeaderBackground,
																						   withItemCache: columnHeaderBackgroundAttributes)
		let attributesHeight = columnHeaderHeight + (collectionView.contentOffset.y < 0 ? abs(collectionView.contentOffset.y) : 0 )
		attributes.frame = CGRect(origin: collectionView.contentOffset, size: CGSize(width: collectionView.frame.width, height: attributesHeight))
		attributes.zIndex = zIndexForElementKind(JZDecorationViewKinds.columnHeaderBackground)
		// Column Header
		let columnHeaderMinY = fmax(collectionView.contentOffset.y, 0.0)
		sectionIndexes.enumerate(_:) { (section, _) in
			let sectionMinMaxXs = sectionsXPoints[section]!
			let sectionMinX = sectionMinMaxXs.minX
			let sectionWidth = sectionMinMaxXs.width
			(attributes, columnHeaderAttributes) = layoutAttributesForSupplemantaryView(at: IndexPath(item: 0, section: section),
																						ofKind: JZSupplementaryViewKinds.columnHeader,
																						withItemCache: columnHeaderAttributes)
			attributes.frame = CGRect(x: sectionMinX, y: columnHeaderMinY, width: sectionWidth, height: columnHeaderHeight)
			attributes.zIndex = zIndexForElementKind(JZSupplementaryViewKinds.columnHeader)
			layoutVerticalGridLinesAttributes(section: section, sectionX: sectionMinX, calendarGridMinY: calendarGridMinY, sectionHeight: sectionHeight)
			layoutItemsAttributes(section: section, sectionX: sectionMinX, calendarStartY: calendarGridMinY)
		}
		layoutHorizontalGridLinesAttributes(calendarStartX: calendarContentMinX, calendarStartY: calendarContentMinY)
	}

	override func layoutItemsAttributes(section: Int, sectionX: CGFloat, calendarStartY: CGFloat) {
		var attributes =  UICollectionViewLayoutAttributes()
		var sectionItemAttributes = [UICollectionViewLayoutAttributes]()
		let sectionWidth = sectionsXPoints[section]!.width
	
		for item in 0..<collectionView!.numberOfItems(inSection: section) {
			let itemIndexPath = IndexPath(item: item, section: section)
			(attributes, itemAttributes) = layoutAttributesForCell(at: itemIndexPath, withItemCache: itemAttributes)
		
			let itemStartTime = startTimeForIndexPath(itemIndexPath)
			let itemEndTime = endTimeForIndexPath(itemIndexPath)
			let startHourY = CGFloat(itemStartTime.hour!) * hourHeight
			let startMinuteY = CGFloat(itemStartTime.minute!) * minuteHeight
			let endHourY: CGFloat
			let endMinuteY = CGFloat(itemEndTime.minute!) * minuteHeight
			
			if itemEndTime.day! != itemStartTime.day! {
				endHourY = CGFloat(Calendar.current.maximumRange(of: .hour)!.count) * hourHeight + CGFloat(itemEndTime.hour!) * hourHeight
			} else {
				endHourY = CGFloat(itemEndTime.hour!) * hourHeight
			}
			
			let itemMinX = (sectionX + itemMargin.left).toDecimal1Value()
			let itemMinY = (startHourY + startMinuteY + calendarStartY + itemMargin.top).toDecimal1Value()
			let itemMaxX = (itemMinX + (sectionWidth - (itemMargin.left + itemMargin.right))).toDecimal1Value()
			let itemMaxY = (endHourY + endMinuteY + calendarStartY - itemMargin.bottom).toDecimal1Value()
			
			attributes.frame = CGRect(x: itemMinX, y: itemMinY, width: itemMaxX - itemMinX, height: itemMaxY - itemMinY)
			attributes.zIndex = zIndexForElementKind(JZSupplementaryViewKinds.eventCell)
			sectionItemAttributes.append(attributes)
		}
		
		adjustItemsForOverlap(sectionItemAttributes, inSection: section, sectionMinX: sectionX,
							  currentSectionZ: zIndexForElementKind(JZSupplementaryViewKinds.eventCell), sectionWidth: sectionWidth)
	}
	
	override open func rectForSection(_ section: Int) -> CGRect {
		let sectionWidth = sectionsXPoints[section]?.width ?? 0
		return CGRect(x: rowHeaderWidth + sectionWidth * CGFloat(section), y: 0,
                      width: sectionWidth, height: collectionViewContentSize.height)
    }
}

extension SectionsFlowLayout {
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
