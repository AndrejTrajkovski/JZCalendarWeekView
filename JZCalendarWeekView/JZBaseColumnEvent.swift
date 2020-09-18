//

import Foundation

public class AppointmentEvent: JZBaseEvent {
	
	public var employeeId: EmployeeId
	public var patient: String?
	public var service: String
	public var color: String?
	
	public init(id: String,
			 patient: String? = nil,
			 service: String = "Botox",
			 color: String? = "#800080",
			 startDate: Date,
			 endDate: Date,
			 employeeId: Int
	) {
		self.patient = patient
		self.service = service
		self.color = color
		self.employeeId = employeeId
		// If you want to have you custom uid, you can set the parent class's id with your uid or UUID().uuidString (In this case, we just use the base class id)
		super.init(id: id, startDate: startDate, endDate: endDate)
	}
	
	public override func copy(with zone: NSZone?) -> Any {
		return AppointmentEvent(id: id, patient: patient, service: service, color: color, startDate: startDate, endDate: endDate, employeeId: employeeId)
	}
}
