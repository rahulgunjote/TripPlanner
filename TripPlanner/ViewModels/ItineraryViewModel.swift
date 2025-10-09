import Foundation
import SwiftData

@MainActor
@Observable
class ItineraryViewModel {
    private var modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // MARK: - Itinerary CRUD Operations
    @discardableResult
    func addItineraryItem(
        to trip: Trip,
        title: String,
        description: String = "",
        date: Date,
        startTime: Date? = nil,
        endTime: Date? = nil,
        location: String = "",
        latitude: Double? = nil,
        longitude: Double? = nil,
        notes: String = ""
    ) -> ItineraryItem {
        let item = ItineraryItem(
            title: title,
            itemDescription: description,
            date: date,
            startTime: startTime,
            endTime: endTime,
            location: location,
            latitude: latitude,
            longitude: longitude,
            notes: notes
        )
        trip.itineraryItems.append(item)
        try? modelContext.save()
        return item
    }
    
    func updateItineraryItem(
        item: ItineraryItem,
        title: String? = nil,
        description: String? = nil,
        date: Date? = nil,
        startTime: Date? = nil,
        endTime: Date? = nil,
        location: String? = nil,
        latitude: Double? = nil,
        longitude: Double? = nil,
        notes: String? = nil,
        isCompleted: Bool? = nil
    ) {
        if let title = title { item.title = title }
        if let description = description { item.itemDescription = description }
        if let date = date { item.date = date }
        if let startTime = startTime { item.startTime = startTime }
        if let endTime = endTime { item.endTime = endTime }
        if let location = location { item.location = location }
        if let latitude = latitude { item.latitude = latitude }
        if let longitude = longitude { item.longitude = longitude }
        if let notes = notes { item.notes = notes }
        if let isCompleted = isCompleted { item.isCompleted = isCompleted }
        try? modelContext.save()
    }
    
    func deleteItineraryItem(from trip: Trip, item: ItineraryItem) {
        if let index = trip.itineraryItems.firstIndex(where: { $0.id == item.id }) {
            trip.itineraryItems.remove(at: index)
            modelContext.delete(item)
            try? modelContext.save()
        }
    }
    
    func toggleCompletion(for item: ItineraryItem) {
        item.isCompleted.toggle()
        try? modelContext.save()
    }
    
    // MARK: - Itinerary Queries
    
    func getItemsByDate(for trip: Trip) -> [(date: Date, items: [ItineraryItem])] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: trip.itineraryItems) { item in
            calendar.startOfDay(for: item.date)
        }
        return grouped.sorted { $0.key < $1.key }.map { (date: $0.key, items: $0.value) }
    }
    
    func getItemsForDate(_ date: Date, in trip: Trip) -> [ItineraryItem] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        
        return trip.itineraryItems.filter { item in
            calendar.isDate(item.date, inSameDayAs: startOfDay)
        }.sorted { item1, item2 in
            // Sort by start time if available, otherwise by title
            if let time1 = item1.startTime, let time2 = item2.startTime {
                return time1 < time2
            }
            return item1.title < item2.title
        }
    }
    
    func getCompletedItems(for trip: Trip) -> [ItineraryItem] {
        trip.itineraryItems.filter { $0.isCompleted }
    }
    
    func getPendingItems(for trip: Trip) -> [ItineraryItem] {
        trip.itineraryItems.filter { !$0.isCompleted }
    }
    
    func getUpcomingItems(for trip: Trip) -> [ItineraryItem] {
        let now = Date()
        return trip.itineraryItems.filter { item in
            item.date >= now && !item.isCompleted
        }.sorted { $0.date < $1.date }
    }
    
    func getTotalItemsCount(for trip: Trip) -> Int {
        trip.itineraryItems.count
    }
    
    func getCompletedItemsCount(for trip: Trip) -> Int {
        getCompletedItems(for: trip).count
    }
    
    func getCompletionPercentage(for trip: Trip) -> Double {
        let total = getTotalItemsCount(for: trip)
        guard total > 0 else { return 0 }
        
        let completed = getCompletedItemsCount(for: trip)
        return Double(completed) / Double(total) * 100
    }
    
    // MARK: - Date Utilities
    
    func getDatesWithItems(for trip: Trip) -> [Date] {
        let calendar = Calendar.current
        let dates = Set(trip.itineraryItems.map { calendar.startOfDay(for: $0.date) })
        return Array(dates).sorted()
    }
    
    func hasItemsOnDate(_ date: Date, in trip: Trip) -> Bool {
        let calendar = Calendar.current
        return trip.itineraryItems.contains { item in
            calendar.isDate(item.date, inSameDayAs: date)
        }
    }
    
    func getItemsCountForDate(_ date: Date, in trip: Trip) -> Int {
        getItemsForDate(date, in: trip).count
    }
    
    // MARK: - Validation
    
    func validateItineraryItem(title: String, date: Date) -> Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    func validateTimeRange(startTime: Date?, endTime: Date?) -> Bool {
        guard let start = startTime, let end = endTime else {
            return true // If one or both are nil, it's valid
        }
        return start < end
    }
    
    func isDateWithinTripRange(date: Date, trip: Trip) -> Bool {
        let calendar = Calendar.current
        let tripStart = calendar.startOfDay(for: trip.startDate)
        let tripEnd = calendar.startOfDay(for: trip.endDate)
        let itemDate = calendar.startOfDay(for: date)
        
        return itemDate >= tripStart && itemDate <= tripEnd
    }
}

