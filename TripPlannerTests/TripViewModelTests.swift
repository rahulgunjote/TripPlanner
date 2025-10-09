import Testing
import SwiftData
import Foundation
@testable import TripPlanner

@MainActor
struct TripViewModelTests {
    var modelContainer: ModelContainer
    var viewModel: TripViewModel
    
    init() async throws {
        let schema = Schema([
            Trip.self,
            Traveller.self,
            ItineraryItem.self,
            Expense.self
        ])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        modelContainer = try ModelContainer(for: schema, configurations: [config])
        viewModel = TripViewModel(modelContext: modelContainer.mainContext)
    }
    
    // MARK: - Trip Operations Tests
    
    @Test("Create Trip - should create trip with valid data")
    func testCreateTrip() async throws {
        let tripName = "Beach Vacation"
        let startDate = Date()
        let endDate = Date().addingTimeInterval(86400 * 7)
        let location = "Malibu"
        
        let trip = viewModel.createTrip(
            name: tripName,
            startDate: startDate,
            endDate: endDate,
            location: location,
            notes: "Relaxing beach trip"
        )
        
        #expect(trip.name == tripName)
        #expect(trip.location == location)
        #expect(trip.notes == "Relaxing beach trip")
    }
    
    @Test("Update Trip - should update trip properties")
    func testUpdateTrip() async throws {
        let trip = viewModel.createTrip(
            name: "Original Name",
            startDate: Date(),
            endDate: Date(),
            location: "Original Location"
        )
        
        viewModel.updateTrip(
            trip: trip,
            name: "Updated Name",
            location: "Updated Location"
        )
        
        #expect(trip.name == "Updated Name")
        #expect(trip.location == "Updated Location")
    }
    
    @Test("Delete Trip - should remove trip from context")
    func testDeleteTrip() async throws {
        let trip = viewModel.createTrip(
            name: "To Be Deleted",
            startDate: Date(),
            endDate: Date(),
            location: "Anywhere"
        )
        
        let tripId = trip.id
        viewModel.deleteTrip(trip)
        
        let allTrips = viewModel.fetchAllTrips()
        let foundTrip = allTrips.first { $0.id == tripId }
        
        #expect(foundTrip == nil)
    }
    
    @Test("Fetch All Trips - should return all trips sorted by date")
    func testFetchAllTrips() async throws {
        let trip1 = viewModel.createTrip(
            name: "Trip 1",
            startDate: Date().addingTimeInterval(-86400 * 10),
            endDate: Date(),
            location: "Location 1"
        )
        
        let trip2 = viewModel.createTrip(
            name: "Trip 2",
            startDate: Date(),
            endDate: Date(),
            location: "Location 2"
        )
        
        let allTrips = viewModel.fetchAllTrips()
        
        #expect(allTrips.count >= 2)
        #expect(allTrips.first?.id == trip2.id) // Most recent first
    }
    
    // MARK: - Trip Queries Tests
    
    @Test("Search Trips - should filter by name")
    func testSearchTripsByName() async throws {
        viewModel.createTrip(
            name: "Beach Vacation",
            startDate: Date(),
            endDate: Date(),
            location: "Hawaii"
        )
        viewModel.createTrip(
            name: "Mountain Hiking",
            startDate: Date(),
            endDate: Date(),
            location: "Colorado"
        )
        
        let results = viewModel.searchTrips(query: "beach")
        
        #expect(results.count == 1)
        #expect(results[0].name == "Beach Vacation")
    }
    
    @Test("Get Upcoming Trips - should return future trips")
    func testGetUpcomingTrips() async throws {
        let futureDate = Date().addingTimeInterval(86400 * 10)
        let pastDate = Date().addingTimeInterval(-86400 * 10)
        
        viewModel.createTrip(
            name: "Future Trip",
            startDate: futureDate,
            endDate: futureDate,
            location: "Future"
        )
        viewModel.createTrip(
            name: "Past Trip",
            startDate: pastDate,
            endDate: pastDate,
            location: "Past"
        )
        
        let upcoming = viewModel.getUpcomingTrips()
        
        #expect(upcoming.count >= 1)
        #expect(upcoming.allSatisfy { $0.startDate >= Date() })
    }
    
    @Test("Get Past Trips - should return completed trips")
    func testGetPastTrips() async throws {
        let pastDate = Date().addingTimeInterval(-86400 * 10)
        
        viewModel.createTrip(
            name: "Past Trip",
            startDate: pastDate,
            endDate: pastDate,
            location: "Past"
        )
        
        let past = viewModel.getPastTrips()
        
        #expect(past.count >= 1)
        #expect(past.allSatisfy { $0.endDate < Date() })
    }
    
    @Test("Get Trip Duration - should calculate days")
    func testGetTripDuration() async throws {
        let startDate = Date()
        let endDate = startDate.addingTimeInterval(86400 * 6) // 7 days total (including start)
        
        let trip = viewModel.createTrip(
            name: "Week Trip",
            startDate: startDate,
            endDate: endDate,
            location: "Location"
        )
        
        let duration = viewModel.getTripDuration(trip)
        
        #expect(duration == 7)
    }
    
    // MARK: - Trip Statistics Tests
    
    @Test("Get Trip Statistics - should calculate all stats")
    func testGetTripStatistics() async throws {
        let trip = viewModel.createTrip(
            name: "Test Trip",
            startDate: Date(),
            endDate: Date().addingTimeInterval(86400 * 4), // 5 days
            location: "Test"
        )
        
        let stats = viewModel.getTripStatistics(for: trip)
        
        #expect(stats.totalDays == 5)
        #expect(stats.totalMembers == 0)
        #expect(stats.totalItineraryItems == 0)
        #expect(stats.completedItineraryItems == 0)
        #expect(stats.totalExpenses == 0)
        #expect(stats.expenseCount == 0)
        #expect(stats.itineraryCompletionPercentage == 0)
    }
    
    // MARK: - Validation Tests
    
    @Test("Validate Trip - valid data")
    func testValidateTripValid() async throws {
        let result = viewModel.validateTrip(
            name: "Valid Trip",
            startDate: Date(),
            endDate: Date().addingTimeInterval(86400),
            location: "Valid Location"
        )
        
        #expect(result.isValid == true)
        #expect(result.errors.isEmpty)
    }
    
    @Test("Validate Trip - empty name")
    func testValidateTripEmptyName() async throws {
        let result = viewModel.validateTrip(
            name: "",
            startDate: Date(),
            endDate: Date(),
            location: "Location"
        )
        
        #expect(result.isValid == false)
        #expect(result.errors.contains("Trip name cannot be empty"))
    }
    
    @Test("Validate Trip - empty location")
    func testValidateTripEmptyLocation() async throws {
        let result = viewModel.validateTrip(
            name: "Trip",
            startDate: Date(),
            endDate: Date(),
            location: ""
        )
        
        #expect(result.isValid == false)
        #expect(result.errors.contains("Location cannot be empty"))
    }
    
    @Test("Validate Trip - invalid dates")
    func testValidateTripInvalidDates() async throws {
        let startDate = Date()
        let endDate = startDate.addingTimeInterval(-86400)
        
        let result = viewModel.validateTrip(
            name: "Trip",
            startDate: startDate,
            endDate: endDate,
            location: "Location"
        )
        
        #expect(result.isValid == false)
        #expect(result.errors.contains("Start date must be before or equal to end date"))
    }
    
    // MARK: - Batch Operations Tests
    
    @Test("Duplicate Trip - should create copy")
    func testDuplicateTrip() async throws {
        let original = viewModel.createTrip(
            name: "Original Trip",
            startDate: Date(),
            endDate: Date(),
            location: "Original Location"
        )
        
        let duplicate = viewModel.duplicateTrip(original)
        
        #expect(duplicate.name == "Original Trip (Copy)")
        #expect(duplicate.location == original.location)
        #expect(duplicate.startDate == original.startDate)
        #expect(duplicate.id != original.id)
    }
}

