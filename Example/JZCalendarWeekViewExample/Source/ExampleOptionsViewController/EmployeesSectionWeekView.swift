import JZCalendarWeekView

class EmployeesSectionWeekView: SectionWeekView {
	
	override func registerViewClasses() {
        super.registerViewClasses()
        self.collectionView.register(UINib(nibName: LongPressEventCell.className, bundle: nil), forCellWithReuseIdentifier: LongPressEventCell.className)
    }
}

class EmployeesSectionWeekViewDataSource: SectionWeekViewDataSource {
	
	override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LongPressEventCell.className, for: indexPath) as? LongPressEventCell,
			let event = getCurrentEvent(with: indexPath) as? AppointmentEvent {
            cell.configureCell(event: event)
            return cell
        }
        preconditionFailure("LongPressEventCell and AllDayEvent should be casted")
    }
}
