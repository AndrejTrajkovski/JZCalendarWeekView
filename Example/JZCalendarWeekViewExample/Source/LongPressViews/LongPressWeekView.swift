//
//  LongPressWeekView.swift
//  JZCalendarWeekViewExample
//
//  Created by Jeff Zhang on 30/4/18.
//  Copyright © 2018 Jeff Zhang. All rights reserved.
//

import UIKit
import JZCalendarWeekView

/// All-Day & Long Press
class LongPressWeekView: JZLongPressWeekView {

    override func registerViewClasses() {
        super.registerViewClasses()

        self.collectionView.register(UINib(nibName: LongPressEventCell.className, bundle: nil), forCellWithReuseIdentifier: LongPressEventCell.className)
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LongPressEventCell.className, for: indexPath) as? LongPressEventCell,
						let event = getCurrentEvent(with: indexPath) {
            cell.configureCell(event: event)
            return cell
        }
        preconditionFailure("LongPressEventCell and AllDayEvent should be casted")
    }

    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        return super.collectionView(collectionView, viewForSupplementaryElementOfKind: kind, at: indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let selectedEvent = getCurrentEvent(with: indexPath) as? AllDayEvent {
            ToastUtil.toastMessageInTheMiddle(message: selectedEvent.title)
        }
    }
}
