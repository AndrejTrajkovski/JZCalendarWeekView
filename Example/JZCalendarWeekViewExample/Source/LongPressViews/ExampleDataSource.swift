import Foundation
import JZCalendarWeekView

class ExampleDataSource: SectionWeekViewDataSource {
	public override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LongPressEventCell.className, for: indexPath) as? LongPressEventCell,
			let event = getCurrentEvent(with: indexPath) as? AppointmentEvent {
			cell.configureCell(event: event)
			return cell
		}
		fatalError("asd")
	}
}
