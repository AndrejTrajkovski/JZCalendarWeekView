//
//  LongPressViewController.swift
//  JZCalendarWeekViewExample
//
//  Created by Jeff Zhang on 30/4/18.
//  Copyright © 2018 Jeff Zhang. All rights reserved.
//

import UIKit
import JZCalendarWeekView

class LongPressViewController: UIViewController, SectionLongPressDelegate {

    @IBOutlet weak var calendarWeekView: EmployeesSectionWeekView!
    let viewModel = DefaultViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupBasic()
        setupCalendarView()
        setupNaviBar()
    }

    // Support device orientation change
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        JZWeekViewHelper.viewTransitionHandler(to: size, weekView: calendarWeekView)
    }

    private func setupCalendarView() {
        calendarWeekView.baseDelegate = self

        if viewModel.currentSelectedData != nil {
            // For example only
            setupCalendarViewWithSelectedData()
        } else {
			calendarWeekView.dataSource = EmployeesSectionWeekViewDataSource()
			calendarWeekView.setupCalendar(setDate: Date(),
										   events: viewModel.eventsByDateOnly)
        }

        // LongPress delegate, datasorce and type setup
		calendarWeekView.sectionLongPressDelegate = self
        calendarWeekView.longPressDelegate = self
        calendarWeekView.longPressDataSource = self
        calendarWeekView.longPressTypes = [.addNew, .move]

        // Optional
        calendarWeekView.addNewDurationMins = 120
        calendarWeekView.moveTimeMinInterval = 15
    }

    /// For example only
    private func setupCalendarViewWithSelectedData() {
    }
}

extension LongPressViewController: JZBaseViewDelegate {
    func initDateDidChange(_ weekView: JZBaseWeekView, initDate: Date) {
        updateNaviBarTitle()
    }
}

// LongPress core
extension LongPressViewController: JZLongPressViewDelegate, JZLongPressViewDataSource {

    func weekView(_ weekView: JZLongPressWeekView, didEndAddNewLongPressAt startDate: Date) {
        let newEvent = AllDayEvent(id: UUID().uuidString, title: "New Event", startDate: startDate, endDate: startDate.add(component: .hour, value: weekView.addNewDurationMins/60),
                             location: "Melbourne", isAllDay: false)
    }

    func weekView(_ weekView: JZLongPressWeekView, editingEvent: JZBaseEvent, didEndMoveLongPressAt startDate: Date) {
    }

    func weekView(_ weekView: JZLongPressWeekView, viewForAddNewLongPressAt startDate: Date) -> UIView {
        if let view = UINib(nibName: EventCell.className, bundle: nil).instantiate(withOwner: nil, options: nil)[0] as? EventCell {
            view.titleLabel.text = "New Event"
            return view
        }
        return UIView()
    }
}

// For example only
extension LongPressViewController: OptionsViewDelegate {

    func setupBasic() {
        // Add this to fix lower than iOS11 problems
        self.automaticallyAdjustsScrollViewInsets = false
    }

    private func setupNaviBar() {
        updateNaviBarTitle()
        let optionsButton = UIButton(type: .system)
        optionsButton.setImage(#imageLiteral(resourceName: "icon_options"), for: .normal)
        optionsButton.frame.size = CGSize(width: 25, height: 25)
        if #available(iOS 11.0, *) {
            optionsButton.widthAnchor.constraint(equalToConstant: 25).isActive = true
            optionsButton.heightAnchor.constraint(equalToConstant: 25).isActive = true
        }
        optionsButton.addTarget(self, action: #selector(presentOptionsVC), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: optionsButton)
    }

    @objc func presentOptionsVC() {
        guard let optionsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "OptionsViewController") as? ExampleOptionsViewController else {
            return
        }
        let optionsViewModel = OptionsViewModel(selectedData: getSelectedData())
        optionsVC.viewModel = optionsViewModel
        optionsVC.delegate = self
        let navigationVC = UINavigationController(rootViewController: optionsVC)
        self.present(navigationVC, animated: true, completion: nil)
    }

    private func getSelectedData() -> OptionsSelectedData {
        let numOfDays = calendarWeekView.numOfDays!
        let firstDayOfWeek = numOfDays == 7 ? calendarWeekView.firstDayOfWeek : nil
        viewModel.currentSelectedData = OptionsSelectedData(viewType: .longPressView,
                                                            date: calendarWeekView.initDate.add(component: .day, value: numOfDays),
                                                            numOfDays: numOfDays,
                                                            scrollType: calendarWeekView.scrollType,
                                                            firstDayOfWeek: firstDayOfWeek,
                                                            hourGridDivision: calendarWeekView.flowLayout.hourGridDivision,
                                                            scrollableRange: calendarWeekView.scrollableRange)
        return viewModel.currentSelectedData
    }

    func finishUpdate(selectedData: OptionsSelectedData) {

        // Update numOfDays
        if selectedData.numOfDays != viewModel.currentSelectedData.numOfDays {
            calendarWeekView.numOfDays = selectedData.numOfDays
            calendarWeekView.refreshWeekView()
        }
        // Update Date
        if selectedData.date != viewModel.currentSelectedData.date {
            calendarWeekView.updateWeekView(to: selectedData.date)
        }
        // Update Scroll Type
        if selectedData.scrollType != viewModel.currentSelectedData.scrollType {
            calendarWeekView.scrollType = selectedData.scrollType
            // If you want to change the scrollType without forceReload, you should call setHorizontalEdgesOffsetX
            calendarWeekView.setHorizontalEdgesOffsetX()
        }
        // Update FirstDayOfWeek
        if selectedData.firstDayOfWeek != viewModel.currentSelectedData.firstDayOfWeek {
            calendarWeekView.updateFirstDayOfWeek(setDate: selectedData.date, firstDayOfWeek: selectedData.firstDayOfWeek)
        }
        // Update hourGridDivision
        if selectedData.hourGridDivision != viewModel.currentSelectedData.hourGridDivision {
            calendarWeekView.updateFlowLayout(JZWeekViewFlowLayout(hourGridDivision: selectedData.hourGridDivision))
        }
        // Update scrollableRange
        if selectedData.scrollableRange != viewModel.currentSelectedData.scrollableRange {
            calendarWeekView.scrollableRange = selectedData.scrollableRange
        }
    }

    private func updateNaviBarTitle() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM YYYY"
        self.navigationItem.title = dateFormatter.string(from: calendarWeekView.initDate.add(component: .day, value: calendarWeekView.numOfDays))
    }
}

// MARK:- SectionLongPressDelegate
extension LongPressViewController {
	public func weekView(_ weekView: JZLongPressWeekView, editingEvent: JZBaseEvent, didEndMoveLongPressAt startDate: Date, pageAndSectionIdx: (Int, Int)) {
		guard let event = editingEvent as? AppointmentEvent else { return }
        let duration = Calendar.current.dateComponents([.minute], from: event.startDate, to: event.endDate).minute!
        let selectedIndex = viewModel.events.firstIndex(where: { $0.id == event.id })!
        viewModel.events[selectedIndex].startDate = startDate
        viewModel.events[selectedIndex].endDate = startDate.add(component: .minute, value: duration)
		if let newId = getWithinPageId(date: startDate, idx: pageAndSectionIdx.1, events: viewModel.eventsByDateOnly as! [Date : [[AppointmentEvent]]]) {
			viewModel.events[selectedIndex].employeeId = newId
		}
        calendarWeekView.forceSectionReload(reloadEvents: viewModel.eventsByDateOnly)
	}

	func getWithinPageId(date: Date,
						 idx: Int,
						 events: [Date: [[AppointmentEvent]]]) -> Int? {
		return events[date.startOfDay]?[safe: idx]?.first?.employeeId
	}

	public func weekView(_ weekView: JZLongPressWeekView, didEndAddNewLongPressAt startDate: Date, pageAndSectionIdx: (Int, Int)) {
		let newIdRange = Array(0...9999)
		let filtered = newIdRange.filter { !viewModel.events.map(\.id).contains(String($0)) }
		let newId = filtered.randomElement()!
		let newEmployeeId = getWithinPageId(date: startDate, idx: pageAndSectionIdx.1, events: viewModel.eventsByDateOnly as! [Date : [[AppointmentEvent]]]) ?? -1
		let newEvent = AppointmentEvent(id: String(newId),
										patient: nil,
										startDate: startDate,
										endDate: startDate.add(component: .hour, value: weekView.addNewDurationMins/60),
										employeeId: newEmployeeId)
		viewModel.events.append(newEvent)
		calendarWeekView.forceSectionReload(reloadEvents: viewModel.eventsByDateOnly)
//		print(startDate)
//		print(pageAndSectionIdx)
	}
}

public extension Collection {
	/// Returns the element at the specified index if it is within bounds, otherwise nil.
	subscript (safe index: Index) -> Element? {
		return indices.contains(index) ? self[index] : nil
	}
}
