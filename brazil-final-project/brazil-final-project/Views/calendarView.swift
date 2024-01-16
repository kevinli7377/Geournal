import SwiftUI
import UIKit

struct CalendarView: UIViewRepresentable {
    
    // View takes in argument of dates
    var decoratedDates: Set<DateComponents>
    var onDateSelected: (DateComponents?) -> Void // closure to handle date selection
    
    func makeUIView(context: Context) -> UICalendarView {
        let calendarView = UICalendarView()
        calendarView.calendar = Calendar(identifier: .gregorian)
        calendarView.availableDateRange = DateInterval(start: Date.distantPast, end: Date.now)
        
        calendarView.tintColor = UIColor(red: 0.3, green: 0.8, blue: 0.9, alpha: 1.0)

        // Set up the selection behavior and delegate
        let selection = UICalendarSelectionSingleDate(delegate: context.coordinator)
        
        calendarView.selectionBehavior = selection
        
        calendarView.delegate = context.coordinator

        return calendarView
    }

    func updateUIView(_ uiView: UICalendarView, context: Context) {
        uiView.reloadDecorations(forDateComponents: Array(decoratedDates), animated: true)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(decoratedDates: decoratedDates, onDateSelected: onDateSelected)
    }

    class Coordinator: NSObject, UICalendarViewDelegate, UICalendarSelectionSingleDateDelegate {
        var decoratedDates: Set<DateComponents>
        var onDateSelected: (DateComponents?) -> Void

        init(decoratedDates: Set<DateComponents>, onDateSelected: @escaping(DateComponents?)->Void) {
            self.decoratedDates = decoratedDates
            self.onDateSelected = onDateSelected
            print("dates in calendarview",decoratedDates)
        }

        func calendarView(_ calendarView: UICalendarView, decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {
            
            let strippedDate = DateComponents(year: dateComponents.year, month: dateComponents.month, day: dateComponents.day)
            
            // Get current day's year, month, and day only
            // as dateComponenets contains a lot of extra information
            
            // For the final app, need to pass dates in as year, month, and day
            
            if decoratedDates.contains(strippedDate){
//                print("Decorating date: \(strippedDate)")
                return UICalendarView.Decoration.default(color: UIColor(red: 0.3, green: 0.8, blue: 0.9, alpha: 1.0), size: .medium)
            } else {
                return nil
            }
        }

        // Implement the required methods of UICalendarSelectionSingleDateDelegate
        func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
            onDateSelected(dateComponents)
        }
    }
}


