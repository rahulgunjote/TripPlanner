import Testing
import Foundation
@testable import TripPlanner

struct TripModelTests {
    
    // MARK: - Trip Model Tests
    
    @Test("Trip Initialization - should initialize with all properties")
    func testTripInitialization() {
        let name = "Summer Vacation"
        let startDate = Date()
        let endDate = Date().addingTimeInterval(86400 * 7)
        let location = "Hawaii"
        let notes = "Beach relaxation"
        
        let trip = Trip(
            name: name,
            startDate: startDate,
            endDate: endDate,
            location: location,
            notes: notes
        )
        
        #expect(trip.name == name)
        #expect(trip.startDate == startDate)
        #expect(trip.endDate == endDate)
        #expect(trip.location == location)
        #expect(trip.notes == notes)
        #expect(trip.travellerIDs.isEmpty)
        #expect(trip.itineraryItems.isEmpty)
        #expect(trip.expenses.isEmpty)
    }
    
    @Test("Trip Date Range String - same day")
    func testDateRangeStringSameDay() {
        let date = Date()
        let trip = Trip(
            name: "Day Trip",
            startDate: date,
            endDate: date,
            location: "Nearby"
        )
        
        let dateRange = trip.dateRangeString
        
        // Should only show one date when same day
        #expect(!dateRange.contains("-"))
    }
    
    @Test("Trip Date Range String - multiple days")
    func testDateRangeStringMultipleDays() {
        let startDate = Date()
        let endDate = startDate.addingTimeInterval(86400 * 3)
        
        let trip = Trip(
            name: "Weekend Trip",
            startDate: startDate,
            endDate: endDate,
            location: "Mountains"
        )
        
        let dateRange = trip.dateRangeString
        
        // Should contain dash when multiple days
        #expect(dateRange.contains("-"))
    }
    
    @Test("Trip Total Expenses - should sum all expenses")
    func testTripTotalExpenses() {
        let trip = Trip(
            name: "Trip",
            startDate: Date(),
            endDate: Date(),
            location: "Location"
        )
        
        let expense1 = Expense(title: "Hotel", amount: 150.00)
        let expense2 = Expense(title: "Food", amount: 75.50)
        let expense3 = Expense(title: "Transport", amount: 50.00)
        
        trip.expenses.append(expense1)
        trip.expenses.append(expense2)
        trip.expenses.append(expense3)
        
        #expect(trip.totalExpenses == 275.50)
    }
    
    @Test("Trip Total Expenses - empty expenses")
    func testTripTotalExpensesEmpty() {
        let trip = Trip(
            name: "Trip",
            startDate: Date(),
            endDate: Date(),
            location: "Location"
        )
        
        #expect(trip.totalExpenses == 0.0)
    }
    
    // MARK: - Traveller Model Tests
    
    @Test("Traveller Initialization - should initialize with all properties")
    func testTravellerInitialization() {
        let name = "Alice Smith"
        let email = "alice@example.com"
        let phone = "555-1234"
        
        let traveller = Traveller(
            name: name,
            email: email,
            phoneNumber: phone
        )
        
        #expect(traveller.name == name)
        #expect(traveller.email == email)
        #expect(traveller.phoneNumber == phone)
    }
    
    @Test("Traveller Initialization - with default values")
    func testTravellerInitializationDefaults() {
        let traveller = Traveller(name: "Bob")
        
        #expect(traveller.name == "Bob")
        #expect(traveller.email.isEmpty)
        #expect(traveller.phoneNumber.isEmpty)
    }
    
    // MARK: - Itinerary Item Model Tests
    
    @Test("Itinerary Item Initialization - should initialize with all properties")
    func testItineraryItemInitialization() {
        let title = "Visit Museum"
        let description = "Art museum downtown"
        let date = Date()
        let location = "Museum District"
        
        let item = ItineraryItem(
            title: title,
            itemDescription: description,
            date: date,
            location: location
        )
        
        #expect(item.title == title)
        #expect(item.itemDescription == description)
        #expect(item.date == date)
        #expect(item.location == location)
        #expect(item.isCompleted == false)
    }
    
    @Test("Itinerary Item Time Range String - with start and end time")
    func testItineraryItemTimeRangeWithBothTimes() {
        let date = Date()
        let startTime = date
        let endTime = date.addingTimeInterval(3600) // 1 hour later
        
        let item = ItineraryItem(
            title: "Activity",
            date: date,
            startTime: startTime,
            endTime: endTime
        )
        
        let timeRange = item.timeRangeString
        
        #expect(timeRange != nil)
        #expect(timeRange!.contains("-"))
    }
    
    @Test("Itinerary Item Time Range String - with only start time")
    func testItineraryItemTimeRangeStartOnly() {
        let date = Date()
        let startTime = date
        
        let item = ItineraryItem(
            title: "Activity",
            date: date,
            startTime: startTime
        )
        
        let timeRange = item.timeRangeString
        
        #expect(timeRange != nil)
        #expect(!timeRange!.contains("-"))
    }
    
    @Test("Itinerary Item Time Range String - no times")
    func testItineraryItemTimeRangeNoTimes() {
        let item = ItineraryItem(
            title: "Activity",
            date: Date()
        )
        
        let timeRange = item.timeRangeString
        
        #expect(timeRange == nil)
    }
    
    @Test("Itinerary Item Completion Toggle - should toggle status")
    func testItineraryItemCompletionToggle() {
        let item = ItineraryItem(
            title: "Task",
            date: Date()
        )
        
        #expect(item.isCompleted == false)
        
        item.isCompleted.toggle()
        #expect(item.isCompleted == true)
        
        item.isCompleted.toggle()
        #expect(item.isCompleted == false)
    }
    
    // MARK: - Expense Model Tests
    
    @Test("Expense Initialization - should initialize with all properties")
    func testExpenseInitialization() {
        let title = "Hotel Room"
        let amount = 250.00
        let currency = "USD"
        let category = ExpenseCategory.accommodation
        let paidBy = "John"
        
        let expense = Expense(
            title: title,
            amount: amount,
            currency: currency,
            category: category,
            paidBy: paidBy
        )
        
        #expect(expense.title == title)
        #expect(expense.amount == amount)
        #expect(expense.currency == currency)
        #expect(expense.category == category)
        #expect(expense.paidBy == paidBy)
    }
    
    @Test("Expense Initialization - with default values")
    func testExpenseInitializationDefaults() {
        let expense = Expense(title: "Item", amount: 100.00)
        
        #expect(expense.title == "Item")
        #expect(expense.amount == 100.00)
        #expect(expense.currency == "USD")
        #expect(expense.category == .other)
        #expect(expense.notes.isEmpty)
        #expect(expense.paidBy.isEmpty)
    }
    
    // MARK: - Expense Category Tests
    
    @Test("Expense Category - all cases should have icons")
    func testExpenseCategoryIcons() {
        for category in ExpenseCategory.allCases {
            #expect(!category.icon.isEmpty)
        }
    }
    
    @Test("Expense Category - accommodation icon")
    func testExpenseCategoryAccommodationIcon() {
        #expect(ExpenseCategory.accommodation.icon == "bed.double.fill")
    }
    
    @Test("Expense Category - transportation icon")
    func testExpenseCategoryTransportationIcon() {
        #expect(ExpenseCategory.transportation.icon == "car.fill")
    }
    
    @Test("Expense Category - food icon")
    func testExpenseCategoryFoodIcon() {
        #expect(ExpenseCategory.food.icon == "fork.knife")
    }
    
    @Test("Expense Category - activities icon")
    func testExpenseCategoryActivitiesIcon() {
        #expect(ExpenseCategory.activities.icon == "ticket.fill")
    }
    
    @Test("Expense Category - shopping icon")
    func testExpenseCategoryShoppingIcon() {
        #expect(ExpenseCategory.shopping.icon == "cart.fill")
    }
    
    @Test("Expense Category - other icon")
    func testExpenseCategoryOtherIcon() {
        #expect(ExpenseCategory.other.icon == "ellipsis.circle.fill")
    }
    
    @Test("Expense Category - raw values")
    func testExpenseCategoryRawValues() {
        #expect(ExpenseCategory.accommodation.rawValue == "Accommodation")
        #expect(ExpenseCategory.transportation.rawValue == "Transportation")
        #expect(ExpenseCategory.food.rawValue == "Food & Dining")
        #expect(ExpenseCategory.activities.rawValue == "Activities")
        #expect(ExpenseCategory.shopping.rawValue == "Shopping")
        #expect(ExpenseCategory.other.rawValue == "Other")
    }
}

