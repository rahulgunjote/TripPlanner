import Foundation
import SwiftData
import SwiftUI

@MainActor
@Observable
class TripViewModel {
    private var modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // MARK: - Trip CRUD Operations
    
    func createTrip(
        name: String,
        startDate: Date,
        endDate: Date,
        location: String,
        latitude: Double? = nil,
        longitude: Double? = nil,
        notes: String = ""
    ) -> Trip {
        let trip = Trip(
            name: name,
            startDate: startDate,
            endDate: endDate,
            location: location,
            latitude: latitude,
            longitude: longitude,
            notes: notes
        )
        
        modelContext.insert(trip)
        try? modelContext.save()
        return trip
    }
    
    func updateTrip(
        trip: Trip,
        name: String? = nil,
        startDate: Date? = nil,
        endDate: Date? = nil,
        location: String? = nil,
        latitude: Double? = nil,
        longitude: Double? = nil,
        notes: String? = nil
    ) {
        if let name = name { trip.name = name }
        if let startDate = startDate { trip.startDate = startDate }
        if let endDate = endDate { trip.endDate = endDate }
        if let location = location { trip.location = location }
        if let latitude = latitude { trip.latitude = latitude }
        if let longitude = longitude { trip.longitude = longitude }
        if let notes = notes { trip.notes = notes }
        
        try? modelContext.save()
    }
    
    func deleteTrip(_ trip: Trip) {
        modelContext.delete(trip)
        try? modelContext.save()
    }
    
    func fetchAllTrips() -> [Trip] {
        let descriptor = FetchDescriptor<Trip>(sortBy: [SortDescriptor(\.startDate, order: .reverse)])
        return (try? modelContext.fetch(descriptor)) ?? []
    }
    
    func searchTrips(query: String) -> [Trip] {
        let allTrips = fetchAllTrips()
        guard !query.isEmpty else { return allTrips }
        
        let lowercasedQuery = query.lowercased()
        return allTrips.filter { trip in
            trip.name.lowercased().contains(lowercasedQuery) ||
            trip.location.lowercased().contains(lowercasedQuery) ||
            trip.notes.lowercased().contains(lowercasedQuery)
        }
    }
    
    // MARK: - Trip Queries
    
    func getUpcomingTrips() -> [Trip] {
        let now = Date()
        return fetchAllTrips().filter { $0.startDate >= now }
    }
    
    func getPastTrips() -> [Trip] {
        let now = Date()
        return fetchAllTrips().filter { $0.endDate < now }
    }
    
    func getCurrentTrips() -> [Trip] {
        let now = Date()
        return fetchAllTrips().filter { trip in
            trip.startDate <= now && trip.endDate >= now
        }
    }
    
    func getTripDuration(_ trip: Trip) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: trip.startDate, to: trip.endDate)
        return max((components.day ?? 0) + 1, 1)
    }
    
    // MARK: - Trip Statistics
    
    func getTripStatistics(for trip: Trip) -> TripStatistics {
        TripStatistics(
            totalDays: getTripDuration(trip),
            totalMembers: trip.travellerIDs.count,
            totalItineraryItems: trip.itineraryItems.count,
            completedItineraryItems: trip.itineraryItems.filter { $0.isCompleted }.count,
            totalExpenses: trip.totalExpenses,
            expenseCount: trip.expenses.count
        )
    }
    
    struct TripStatistics {
        let totalDays: Int
        let totalMembers: Int
        let totalItineraryItems: Int
        let completedItineraryItems: Int
        let totalExpenses: Double
        let expenseCount: Int
        
        var itineraryCompletionPercentage: Double {
            guard totalItineraryItems > 0 else { return 0 }
            return Double(completedItineraryItems) / Double(totalItineraryItems) * 100
        }
        
        var averageExpensePerDay: Double {
            guard totalDays > 0 else { return 0 }
            return totalExpenses / Double(totalDays)
        }
        
        var averageExpensePerMember: Double {
            guard totalMembers > 0 else { return 0 }
            return totalExpenses / Double(totalMembers)
        }
    }
    
    // MARK: - Validation
    
    func validateTrip(name: String, startDate: Date, endDate: Date, location: String) -> ValidationResult {
        var errors: [String] = []
        
        if name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errors.append("Trip name cannot be empty")
        }
        
        if location.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errors.append("Location cannot be empty")
        }
        
        if startDate > endDate {
            errors.append("Start date must be before or equal to end date")
        }
        
        return ValidationResult(isValid: errors.isEmpty, errors: errors)
    }
    
    struct ValidationResult {
        let isValid: Bool
        let errors: [String]
        
        var errorMessage: String {
            errors.joined(separator: ", ")
        }
    }
    
    // MARK: - Batch Operations
    
    func duplicateTrip(_ trip: Trip) -> Trip {
        let newTrip = Trip(
            name: "\(trip.name) (Copy)",
            startDate: trip.startDate,
            endDate: trip.endDate,
            location: trip.location,
            latitude: trip.latitude,
            longitude: trip.longitude,
            notes: trip.notes
        )
        
        modelContext.insert(newTrip)
        try? modelContext.save()
        return newTrip
    }
}

