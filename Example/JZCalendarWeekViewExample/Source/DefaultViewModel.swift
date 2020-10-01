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

	private let firstDate = Date().add(component: .day, value: -1)
														.add(component: .hour, value: 2)
    private let secondDate = Date().add(component: .hour, value: 2)
    private let thirdDate = Date().add(component: .day, value: 1)
															.add(component: .hour, value: 2)
	private let fourthDate = Date().add(component: .day, value: -2)
		.add(component: .hour, value: 2)

	lazy var events = [
		AppointmentEvent(id: "10", startDate: fourthDate, endDate: fourthDate.add(component: .hour, value: 1), employeeId: 10),
		AppointmentEvent(id: "1", startDate: firstDate, endDate: firstDate.add(component: .hour, value: 1), employeeId: 1),
		AppointmentEvent(id: "2", startDate: firstDate, endDate: firstDate.add(component: .hour, value: 1), employeeId: 1),
		AppointmentEvent(id: "3", startDate: firstDate, endDate: firstDate.add(component: .hour, value: 1), employeeId: 1),
		AppointmentEvent(id: "4", startDate: secondDate, endDate: secondDate.add(component: .hour, value: 1), employeeId: 4),
		AppointmentEvent(id: "5", startDate: secondDate, endDate: secondDate.add(component: .hour, value: 1), employeeId: 4),
		AppointmentEvent(id: "6", startDate: secondDate, endDate: secondDate.add(component: .hour, value: 1), employeeId: 6),
		AppointmentEvent(id: "7", startDate: thirdDate, endDate: thirdDate.add(component: .hour, value: 1), employeeId: 1),
		AppointmentEvent(id: "8", startDate: thirdDate, endDate: thirdDate.add(component: .hour, value: 1), employeeId: 1),
		AppointmentEvent(id: "9", startDate: thirdDate, endDate: thirdDate.add(component: .hour, value: 1), employeeId: 14)
	]
	    lazy var eventsByDate = JZWeekViewHelper.getIntraEventsByDate(originalEvents: events)
//	var eventsByDate: MyDataSource { JZWeekViewHelper.getIntraEventsByEmployee(originalEvents: events) }
	var eventsByDateAndSections: [Date: [[JZBaseEvent]]] { JZWeekViewHelper.groupEventsByPageAndSections(originalEvents: events,
																										 grouping: \.employeeId,
																										 sorting: { v1, v2 in
																									v1.key < v2.key
	})
	}
	
	var eventsByDateOnly: [Date: [[JZBaseEvent]]] {
		JZWeekViewHelper.getIntraEventsByDate(originalEvents: events)
			.mapValues {
				[$0]
		}
	}

	var currentSelectedData: OptionsSelectedData!
}

class DefaultViewModel2: NSObject {

    private let firstDate = Date().add(component: .hour, value: 1)
    private let secondDate = Date().add(component: .day, value: 1)
    private let thirdDate = Date().add(component: .day, value: 2)

    lazy var events = [DefaultEvent(id: "0", title: "One", startDate: firstDate, endDate: firstDate.add(component: .hour, value: 1), location: "Melbourne"),
                       DefaultEvent(id: "1", title: "Two", startDate: secondDate, endDate: secondDate.add(component: .hour, value: 4), location: "Sydney"),
                       DefaultEvent(id: "2", title: "Three", startDate: thirdDate, endDate: thirdDate.add(component: .hour, value: 2), location: "Tasmania"),
                       DefaultEvent(id: "3", title: "Four", startDate: thirdDate, endDate: thirdDate.add(component: .hour, value: 26), location: "Canberra")]

    lazy var eventsByDate = JZWeekViewHelper.getIntraEventsByDate(originalEvents: events)

    var currentSelectedData: OptionsSelectedData!
}
