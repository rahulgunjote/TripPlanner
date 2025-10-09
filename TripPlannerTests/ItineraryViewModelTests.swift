import Testing
import SwiftData
import Foundation
@testable import TripPlanner

@MainActor
struct ItineraryViewModelTests {
    var modelContainer: ModelContainer
    var viewModel: ItineraryViewModel
    var trip: Trip
    
    init() async throws {
        let schema = Schema([
            Trip.self,
            Traveller.self,
            ItineraryItem.self,
            Expense.self
        ])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        modelContainer = try ModelContainer(for: schema, configurations: [config])
        viewModel = ItineraryViewModel(modelContext: modelContainer.mainContext)
        
        // Create a test trip
        let startDate = Date()
        let endDate = startDate.addingTimeInterval(86400 * 7)
        trip = Trip(
            name: "Test Trip",
            startDate: startDate,
            endDate: endDate,
            location: "Test Location"
        )
        modelContainer.mainContext.insert(trip)
        try modelContainer.mainContext.save()
    }
    
    // MARK: - Itinerary CRUD Tests
    
    @Test("Add Itinerary Item - should create item with all properties")
    func testAddItineraryItem() async throws {
        let date = Date()
        let item = viewModel.addItineraryItem(
            to: trip,
            title: "Visit Museum",
            description: "Art museum",
            date: date,
            location: "Downtown"
        )
        
        #expect(trip.itineraryItems.count == 1)
        #expect(item.title == "Visit Museum")
        #expect(item.itemDescription == "Art museum")
        #expect(item.location == "Downtown")
        #expect(item.isCompleted == false)
    }
    
    @Test("Update Itinerary Item - should update item properties")
    func testUpdateItineraryItem() async throws {
        let item = viewModel.addItineraryItem(
            to: trip,
            title: "Original",
            date: Date()
        )
        
        viewModel.updateItineraryItem(
            item: item,
            title: "Updated",
            description: "New description",
            isCompleted: true
        )
        
        #expect(item.title == "Updated")
        #expect(item.itemDescription == "New description")
        #expect(item.isCompleted == true)
    }
    
    @Test("Delete Itinerary Item - should remove item from trip")
    func testDeleteItineraryItem() async throws {
        let item = viewModel.addItineraryItem(
            to: trip,
            title: "Test",
            date: Date()
        )
        
        #expect(trip.itineraryItems.count == 1)
        
        viewModel.deleteItineraryItem(from: trip, item: item)
        
        #expect(trip.itineraryItems.count == 0)
    }
    
    @Test("Toggle Completion - should toggle completion status")
    func testToggleCompletion() async throws {
        let item = viewModel.addItineraryItem(
            to: trip,
            title: "Task",
            date: Date()
        )
        
        #expect(item.isCompleted == false)
        
        viewModel.toggleCompletion(for: item)
        #expect(item.isCompleted == true)
        
        viewModel.toggleCompletion(for: item)
        #expect(item.isCompleted == false)
    }
    
    // MARK: - Itinerary Queries Tests
    
    @Test("Get Items By Date - should group by date")
    func testGetItemsByDate() async throws {
        let date1 = Date()
        let date2 = date1.addingTimeInterval(86400)
        
        viewModel.addItineraryItem(to: trip, title: "Item 1", date: date1)
        viewModel.addItineraryItem(to: trip, title: "Item 2", date: date1)
        viewModel.addItineraryItem(to: trip, title: "Item 3", date: date2)
        
        let grouped = viewModel.getItemsByDate(for: trip)
        
        #expect(grouped.count == 2)
        
        let firstDayItems = grouped.first { Calendar.current.isDate($0.date, inSameDayAs: date1) }
        #expect(firstDayItems?.items.count == 2)
        
        let secondDayItems = grouped.first { Calendar.current.isDate($0.date, inSameDayAs: date2) }
        #expect(secondDayItems?.items.count == 1)
    }
    
    @Test("Get Items For Date - should return items for specific date")
    func testGetItemsForDate() async throws {
        let targetDate = Date()
        let otherDate = targetDate.addingTimeInterval(86400)
        
        viewModel.addItineraryItem(to: trip, title: "Target 1", date: targetDate)
        viewModel.addItineraryItem(to: trip, title: "Target 2", date: targetDate)
        viewModel.addItineraryItem(to: trip, title: "Other", date: otherDate)
        
        let items = viewModel.getItemsForDate(targetDate, in: trip)
        
        #expect(items.count == 2)
        #expect(items.allSatisfy { Calendar.current.isDate($0.date, inSameDayAs: targetDate) })
    }
    
    @Test("Get Completed Items - should return only completed")
    func testGetCompletedItems() async throws {
        let item1 = viewModel.addItineraryItem(to: trip, title: "Completed", date: Date())
        let item2 = viewModel.addItineraryItem(to: trip, title: "Pending", date: Date())
        let item3 = viewModel.addItineraryItem(to: trip, title: "Completed 2", date: Date())
        
        viewModel.toggleCompletion(for: item1)
        viewModel.toggleCompletion(for: item3)
        
        let completed = viewModel.getCompletedItems(for: trip)
        
        #expect(completed.count == 2)
        #expect(completed.allSatisfy { $0.isCompleted })
    }
    
    @Test("Get Pending Items - should return only pending")
    func testGetPendingItems() async throws {
        let item1 = viewModel.addItineraryItem(to: trip, title: "Completed", date: Date())
        let item2 = viewModel.addItineraryItem(to: trip, title: "Pending", date: Date())
        
        viewModel.toggleCompletion(for: item1)
        
        let pending = viewModel.getPendingItems(for: trip)
        
        #expect(pending.count == 1)
        #expect(pending.allSatisfy { !$0.isCompleted })
    }
    
    @Test("Get Upcoming Items - should return future incomplete items")
    func testGetUpcomingItems() async throws {
        let pastDate = Date().addingTimeInterval(-86400)
        let futureDate = Date().addingTimeInterval(86400)
        
        viewModel.addItineraryItem(to: trip, title: "Past", date: pastDate)
        let upcomingItem = viewModel.addItineraryItem(to: trip, title: "Future", date: futureDate)
        let completedFutureItem = viewModel.addItineraryItem(to: trip, title: "Completed Future", date: futureDate)
        
        viewModel.toggleCompletion(for: completedFutureItem)
        
        let upcoming = viewModel.getUpcomingItems(for: trip)
        
        #expect(upcoming.count == 1)
        #expect(upcoming[0].title == "Future")
    }
    
    @Test("Get Total Items Count - should count all items")
    func testGetTotalItemsCount() async throws {
        viewModel.addItineraryItem(to: trip, title: "Item 1", date: Date())
        viewModel.addItineraryItem(to: trip, title: "Item 2", date: Date())
        viewModel.addItineraryItem(to: trip, title: "Item 3", date: Date())
        
        let count = viewModel.getTotalItemsCount(for: trip)
        
        #expect(count == 3)
    }
    
    @Test("Get Completed Items Count - should count completed")
    func testGetCompletedItemsCount() async throws {
        let item1 = viewModel.addItineraryItem(to: trip, title: "Item 1", date: Date())
        let item2 = viewModel.addItineraryItem(to: trip, title: "Item 2", date: Date())
        viewModel.addItineraryItem(to: trip, title: "Item 3", date: Date())
        
        viewModel.toggleCompletion(for: item1)
        viewModel.toggleCompletion(for: item2)
        
        let count = viewModel.getCompletedItemsCount(for: trip)
        
        #expect(count == 2)
    }
    
    @Test("Get Completion Percentage - should calculate percentage")
    func testGetCompletionPercentage() async throws {
        let item1 = viewModel.addItineraryItem(to: trip, title: "Item 1", date: Date())
        viewModel.addItineraryItem(to: trip, title: "Item 2", date: Date())
        viewModel.addItineraryItem(to: trip, title: "Item 3", date: Date())
        viewModel.addItineraryItem(to: trip, title: "Item 4", date: Date())
        
        viewModel.toggleCompletion(for: item1)
        
        let percentage = viewModel.getCompletionPercentage(for: trip)
        
        #expect(percentage == 25.0) // 1 out of 4 = 25%
    }
    
    @Test("Get Completion Percentage - empty list")
    func testGetCompletionPercentageEmpty() async throws {
        let percentage = viewModel.getCompletionPercentage(for: trip)
        
        #expect(percentage == 0.0)
    }
    
    // MARK: - Date Utilities Tests
    
    @Test("Get Dates With Items - should return unique dates")
    func testGetDatesWithItems() async throws {
        let date1 = Date()
        let date2 = date1.addingTimeInterval(86400)
        let date3 = date1.addingTimeInterval(86400 * 2)
        
        viewModel.addItineraryItem(to: trip, title: "Item 1", date: date1)
        viewModel.addItineraryItem(to: trip, title: "Item 2", date: date1)
        viewModel.addItineraryItem(to: trip, title: "Item 3", date: date2)
        viewModel.addItineraryItem(to: trip, title: "Item 4", date: date3)
        
        let dates = viewModel.getDatesWithItems(for: trip)
        
        #expect(dates.count == 3)
    }
    
    @Test("Has Items On Date - should return true when items exist")
    func testHasItemsOnDateTrue() async throws {
        let date = Date()
        viewModel.addItineraryItem(to: trip, title: "Item", date: date)
        
        let hasItems = viewModel.hasItemsOnDate(date, in: trip)
        
        #expect(hasItems == true)
    }
    
    @Test("Has Items On Date - should return false when no items")
    func testHasItemsOnDateFalse() async throws {
        let date = Date()
        let otherDate = date.addingTimeInterval(86400)
        viewModel.addItineraryItem(to: trip, title: "Item", date: otherDate)
        
        let hasItems = viewModel.hasItemsOnDate(date, in: trip)
        
        #expect(hasItems == false)
    }
    
    @Test("Get Items Count For Date - should count items")
    func testGetItemsCountForDate() async throws {
        let date = Date()
        let otherDate = date.addingTimeInterval(86400)
        
        viewModel.addItineraryItem(to: trip, title: "Item 1", date: date)
        viewModel.addItineraryItem(to: trip, title: "Item 2", date: date)
        viewModel.addItineraryItem(to: trip, title: "Item 3", date: otherDate)
        
        let count = viewModel.getItemsCountForDate(date, in: trip)
        
        #expect(count == 2)
    }
    
    // MARK: - Validation Tests
    
    @Test("Validate Itinerary Item - valid inputs")
    func testValidateItineraryItemValid() async throws {
        #expect(viewModel.validateItineraryItem(title: "Visit Museum", date: Date()) == true)
        #expect(viewModel.validateItineraryItem(title: "A", date: Date()) == true)
    }
    
    @Test("Validate Itinerary Item - invalid inputs")
    func testValidateItineraryItemInvalid() async throws {
        #expect(viewModel.validateItineraryItem(title: "", date: Date()) == false)
        #expect(viewModel.validateItineraryItem(title: "   ", date: Date()) == false)
    }
    
    @Test("Validate Time Range - valid ranges")
    func testValidateTimeRangeValid() async throws {
        let start = Date()
        let end = start.addingTimeInterval(3600)
        
        #expect(viewModel.validateTimeRange(startTime: start, endTime: end) == true)
        #expect(viewModel.validateTimeRange(startTime: nil, endTime: nil) == true)
        #expect(viewModel.validateTimeRange(startTime: start, endTime: nil) == true)
    }
    
    @Test("Validate Time Range - invalid ranges")
    func testValidateTimeRangeInvalid() async throws {
        let start = Date()
        let end = start.addingTimeInterval(-3600) // End before start
        
        #expect(viewModel.validateTimeRange(startTime: start, endTime: end) == false)
    }
    
    @Test("Is Date Within Trip Range - valid dates")
    func testIsDateWithinTripRangeValid() async throws {
        let midDate = trip.startDate.addingTimeInterval(86400 * 3)
        
        #expect(viewModel.isDateWithinTripRange(date: trip.startDate, trip: trip) == true)
        #expect(viewModel.isDateWithinTripRange(date: midDate, trip: trip) == true)
        #expect(viewModel.isDateWithinTripRange(date: trip.endDate, trip: trip) == true)
    }
    
    @Test("Is Date Within Trip Range - invalid dates")
    func testIsDateWithinTripRangeInvalid() async throws {
        let beforeStart = trip.startDate.addingTimeInterval(-86400)
        let afterEnd = trip.endDate.addingTimeInterval(86400)
        
        #expect(viewModel.isDateWithinTripRange(date: beforeStart, trip: trip) == false)
        #expect(viewModel.isDateWithinTripRange(date: afterEnd, trip: trip) == false)
    }
}

