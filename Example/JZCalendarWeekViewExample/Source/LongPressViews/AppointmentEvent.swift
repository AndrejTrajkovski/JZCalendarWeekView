import Foundation
import JZCalendarWeekView

public class AppointmentEvent: JZBaseEvent {
		
	public override var debugDescription: String {
		return "id: \(id), employeeId: \(employeeId)"
	}
	
	public var roomId: Int
	public var employeeId: Int
	public var patient: String?
	public var service: String
	public var color: String?
	
	public init(id: String,
			 patient: String? = nil,
			 service: String = "Botox",
			 color: String? = "#800080",
			 startDate: Date,
			 endDate: Date,
			 employeeId: Int,
			 roomId: Int = 1
	) {
		self.roomId = roomId
		self.patient = patient
		self.service = service
		self.color = color
		self.employeeId = employeeId
		// If you want to have you custom uid, you can set the parent class's id with your uid or UUID().uuidString (In this case, we just use the base class id)
		super.init(id: id, startDate: startDate, endDate: endDate)
	}
	
	public override func copy(with zone: NSZone?) -> Any {
		return AppointmentEvent(id: id, patient: patient, service: service, color: color, startDate: startDate, endDate: endDate, employeeId: employeeId, roomId: roomId)
	}
}

public extension SectionGrouping where A == AppointmentEvent, K == Int {
	static let byEmployee = SectionGrouping(
		group: { array in return Dictionary.init(grouping: array, by: { $0.employeeId }) }
	)

	static let byRoom = SectionGrouping(
		group: { array in return Dictionary.init(grouping: array, by: { $0.roomId }) }
	)
}

public extension SectionSorting where A == AppointmentEvent, K == Int {
	static let byAppointmentCount = SectionSorting<AppointmentEvent, Int> {
		$0.value.count > $1.value.count
	}

	static let byEmployeeId = SectionSorting<AppointmentEvent, Int> {
		$0.key < $1.key
	}
}