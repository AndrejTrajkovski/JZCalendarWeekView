//
//  DefaultViewModel.swift
//  JZCalendarViewExample
//
//  Created by Jeff Zhang on 3/4/18.
//  Copyright © 2018 Jeff Zhang. All rights reserved.
//

import UIKit
import JZCalendarWeekView

class DefaultViewModel: NSObject {

    private let firstDate = Date().add(component: .hour, value: 1)
    private let secondDate = Date().add(component: .hour, value: 12)
    private let thirdDate = Date().add(component: .hour, value: -12)
		private let fourthDate = Date().add(component: .day, value: 1)
	
	lazy var events = [
		AppointmentEvent(id: "0", startDate: firstDate, endDate: firstDate.add(component: .hour, value: 1), employeeId: 1),
										 AppointmentEvent(id: "1", startDate: secondDate, endDate: secondDate.add(component: .hour, value: 4), employeeId: 1),
										 AppointmentEvent(id: "5", startDate: firstDate, endDate: firstDate.add(component: .hour, value: 1), employeeId: 2),
										 AppointmentEvent(id: "6", startDate: secondDate, endDate: secondDate.add(component: .hour, value: 4), employeeId: 3),
										 AppointmentEvent(id: "2", startDate: thirdDate, endDate: thirdDate.add(component: .hour, value: 2), employeeId: 4),
										 AppointmentEvent(id: "3", startDate: thirdDate, endDate: thirdDate.add(component: .hour, value: 2), employeeId: 5),
										 AppointmentEvent(id: "7", startDate: fourthDate, endDate: fourthDate.add(component: .hour, value: 2), employeeId: 6)
										 ]
	
	//    lazy var eventsByDate = JZWeekViewHelper.getIntraEventsByDate(originalEvents: events)
	lazy var eventsByDate = JZWeekViewHelper.getIntraEventsByEmployee(originalEvents: events)
	
	var currentSelectedData: OptionsSelectedData!
}
