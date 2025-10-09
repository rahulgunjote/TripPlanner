import Foundation
import SwiftData
import SwiftUI

@Model
final class Trip {
    var id: UUID
    var name: String
    var startDate: Date
    var endDate: Date
    var location: String
    var latitude: Double?
    var longitude: Double?
    var notes: String
    
    // Store traveller IDs instead of direct relationship to avoid coupling
    var travellerIDs: [String]
    
    @Relationship(deleteRule: .cascade)
    var itineraryItems: [ItineraryItem]
    
    @Relationship(deleteRule: .cascade)
    var expenses: [Expense]
    
    init(
        id: UUID = UUID(),
        name: String,
        startDate: Date,
        endDate: Date,
        location: String,
        latitude: Double? = nil,
        longitude: Double? = nil,
        notes: String = "",
        travellerIDs: [String] = [],
        itineraryItems: [ItineraryItem] = [],
        expenses: [Expense] = []
    ) {
        self.id = id
        self.name = name
        self.startDate = startDate
        self.endDate = endDate
        self.location = location
        self.latitude = latitude
        self.longitude = longitude
        self.notes = notes
        self.travellerIDs = travellerIDs
        self.itineraryItems = itineraryItems
        self.expenses = expenses
    }
    
    var dateRangeString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        
        if Calendar.current.isDate(startDate, inSameDayAs: endDate) {
            return formatter.string(from: startDate)
        } else {
            return "\(formatter.string(from: startDate)) - \(formatter.string(from: endDate))"
        }
    }
    
    var totalExpenses: Double {
        expenses.reduce(0) { $0 + $1.amount }
    }
}

