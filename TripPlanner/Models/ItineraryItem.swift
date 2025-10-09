import Foundation
import SwiftData

@Model
final class ItineraryItem {
    var id: UUID
    var title: String
    var itemDescription: String
    var date: Date
    var startTime: Date?
    var endTime: Date?
    var location: String
    var latitude: Double?
    var longitude: Double?
    var notes: String
    var isCompleted: Bool
    
    init(
        id: UUID = UUID(),
        title: String,
        itemDescription: String = "",
        date: Date,
        startTime: Date? = nil,
        endTime: Date? = nil,
        location: String = "",
        latitude: Double? = nil,
        longitude: Double? = nil,
        notes: String = "",
        isCompleted: Bool = false
    ) {
        self.id = id
        self.title = title
        self.itemDescription = itemDescription
        self.date = date
        self.startTime = startTime
        self.endTime = endTime
        self.location = location
        self.latitude = latitude
        self.longitude = longitude
        self.notes = notes
        self.isCompleted = isCompleted
    }
    
    var timeRangeString: String? {
        guard let startTime = startTime else { return nil }
        
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        
        if let endTime = endTime {
            return "\(formatter.string(from: startTime)) - \(formatter.string(from: endTime))"
        } else {
            return formatter.string(from: startTime)
        }
    }
}

