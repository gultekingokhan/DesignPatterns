// Design Patterns: Adapter

import EventKit

// Models

protocol Event: class {
    var title: String { get }
    var startDate: String { get }
    var endDate: String { get }
}

extension Event {
    var description: String {
        return "Name: \(title)\nEvent start: \(startDate)\nEvent end: \(endDate)"
    }
}

class LocalEvent: Event {
    var title: String
    var startDate: String
    var endDate: String
    
    init(title: String, startDate: String, endDate: String) {
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
    }
}

// Adapter

class EKEventAdapter: Event {
    private var event: EKEvent
    
    private lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy HH:mm"
        return dateFormatter
    }()
    
    var title: String {
        return event.title
    }
    var startDate: String {
        return dateFormatter.string(from: event.startDate)
    }
    var endDate: String {
        return dateFormatter.string(from: event.endDate)
    }
    
    init(event: EKEvent) {
        self.event = event
    }
}

// Usage

let dateFormatter = DateFormatter()
dateFormatter.dateFormat = "MM/dd/yyyy HH:mm"

let eventStore = EKEventStore()
let event = EKEvent(eventStore: eventStore)
event.title = "Design Pattern Meetup"
event.startDate = dateFormatter.date(from: "06/29/2018 18:00")
event.endDate = dateFormatter.date(from: "06/29/2018 19:30")

let adapter = EKEventAdapter(event: event)
adapter.description

// Result:
// Name: Design Pattern Meetup
// Event start: 06-29-2018 18:00
// Event end: 06-29-2018 19:30
