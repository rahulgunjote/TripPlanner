import Testing
import SwiftData
import Foundation
@testable import TripPlanner

@MainActor
struct ExpenseViewModelTests {
    var modelContainer: ModelContainer
    var viewModel: ExpenseViewModel
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
        viewModel = ExpenseViewModel(modelContext: modelContainer.mainContext)
        
        // Create a test trip
        trip = Trip(
            name: "Test Trip",
            startDate: Date(),
            endDate: Date().addingTimeInterval(86400 * 7),
            location: "Test Location"
        )
        modelContainer.mainContext.insert(trip)
        try modelContainer.mainContext.save()
    }
    
    // MARK: - Expense CRUD Tests
    
    @Test("Add Expense - should create expense with all properties")
    func testAddExpense() async throws {
        let expense = viewModel.addExpense(
            to: trip,
            title: "Hotel",
            amount: 200.0,
            currency: "USD",
            category: .accommodation,
            paidBy: "John"
        )
        
        #expect(trip.expenses.count == 1)
        #expect(expense.title == "Hotel")
        #expect(expense.amount == 200.0)
        #expect(expense.currency == "USD")
        #expect(expense.category == .accommodation)
        #expect(expense.paidBy == "John")
    }
    
    @Test("Update Expense - should update expense properties")
    func testUpdateExpense() async throws {
        let expense = viewModel.addExpense(
            to: trip,
            title: "Original",
            amount: 100.0
        )
        
        viewModel.updateExpense(
            expense: expense,
            title: "Updated",
            amount: 150.0,
            category: .food
        )
        
        #expect(expense.title == "Updated")
        #expect(expense.amount == 150.0)
        #expect(expense.category == .food)
    }
    
    @Test("Delete Expense - should remove expense from trip")
    func testDeleteExpense() async throws {
        let expense = viewModel.addExpense(
            to: trip,
            title: "Test",
            amount: 50.0
        )
        
        #expect(trip.expenses.count == 1)
        
        viewModel.deleteExpense(from: trip, expense: expense)
        
        #expect(trip.expenses.count == 0)
    }
    
    // MARK: - Expense Calculations Tests
    
    @Test("Calculate Total Expenses - should sum all expenses")
    func testCalculateTotalExpenses() async throws {
        viewModel.addExpense(to: trip, title: "Expense 1", amount: 100.0)
        viewModel.addExpense(to: trip, title: "Expense 2", amount: 50.0)
        viewModel.addExpense(to: trip, title: "Expense 3", amount: 25.50)
        
        let total = viewModel.calculateTotalExpenses(for: trip)
        
        #expect(total == 175.50)
    }
    
    @Test("Calculate Expenses By Category - should group by category")
    func testCalculateExpensesByCategory() async throws {
        viewModel.addExpense(to: trip, title: "Hotel", amount: 200.0, category: .accommodation)
        viewModel.addExpense(to: trip, title: "Flight", amount: 300.0, category: .transportation)
        viewModel.addExpense(to: trip, title: "Breakfast", amount: 30.0, category: .food)
        viewModel.addExpense(to: trip, title: "Dinner", amount: 50.0, category: .food)
        
        let byCategory = viewModel.calculateExpensesByCategory(for: trip)
        
        #expect(byCategory[.accommodation] == 200.0)
        #expect(byCategory[.transportation] == 300.0)
        #expect(byCategory[.food] == 80.0)
    }
    
    @Test("Get Sorted Expenses - should sort by date descending")
    func testGetSortedExpenses() async throws {
        let date1 = Date().addingTimeInterval(-86400 * 2)
        let date2 = Date().addingTimeInterval(-86400)
        let date3 = Date()
        
        viewModel.addExpense(to: trip, title: "Old", amount: 100.0, date: date1)
        viewModel.addExpense(to: trip, title: "Recent", amount: 50.0, date: date3)
        viewModel.addExpense(to: trip, title: "Middle", amount: 75.0, date: date2)
        
        let sorted = viewModel.getSortedExpenses(for: trip)
        
        #expect(sorted.count == 3)
        #expect(sorted[0].title == "Recent")
        #expect(sorted[1].title == "Middle")
        #expect(sorted[2].title == "Old")
    }
    
    // MARK: - Member Share Calculations Tests
    
    @Test("Calculate Member Shares - single member, single expense")
    func testCalculateMemberSharesSingleMemberSingleExpense() async throws {
        let member = Traveller(name: "Alice", travellerType: .adult)
        modelContainer.mainContext.insert(member)
        try modelContainer.mainContext.save()
        trip.travellerIDs.append(member.id.uuidString)
        
        viewModel.addExpense(
            to: trip,
            title: "Hotel",
            amount: 100.0,
            paidBy: "Alice",
            sharedByMemberIds: [member.id.uuidString]
        )
        
        let shares = viewModel.calculateTravellerShares(for: trip, travellers: [member])
        
        #expect(shares.count == 1)
        #expect(shares[0].traveller.name == "Alice")
        #expect(shares[0].share == 100.0)
        #expect(shares[0].paid == 100.0)
        #expect(shares[0].balance == 0.0)
    }
    
    @Test("Calculate Member Shares - multiple members sharing expense")
    func testCalculateMemberSharesMultipleMembersSharing() async throws {
        let alice = Traveller(name: "Alice", travellerType: .adult)
        let bob = Traveller(name: "Bob", travellerType: .adult)
        modelContainer.mainContext.insert(alice)
        modelContainer.mainContext.insert(bob)
        try modelContainer.mainContext.save()
        trip.travellerIDs.append(contentsOf: [alice.id.uuidString, bob.id.uuidString])
        
        viewModel.addExpense(
            to: trip,
            title: "Dinner",
            amount: 100.0,
            paidBy: "Alice",
            sharedByMemberIds: [alice.id.uuidString, bob.id.uuidString]
        )
        
        let shares = viewModel.calculateTravellerShares(for: trip, travellers: [alice, bob])
        
        #expect(shares.count == 2)
        
        let aliceShare = shares.first { $0.traveller.name == "Alice" }
        #expect(aliceShare?.share == 50.0)
        #expect(aliceShare?.paid == 100.0)
        #expect(aliceShare?.balance == 50.0) // Owed 50
        
        let bobShare = shares.first { $0.traveller.name == "Bob" }
        #expect(bobShare?.share == 50.0)
        #expect(bobShare?.paid == 0.0)
        #expect(bobShare?.balance == -50.0) // Owes 50
    }
    
    @Test("Calculate Member Shares - complex scenario")
    func testCalculateMemberSharesComplex() async throws {
        let alice = Traveller(name: "Alice", travellerType: .adult)
        let bob = Traveller(name: "Bob", travellerType: .adult)
        let charlie = Traveller(name: "Charlie", travellerType: .adult)
        modelContainer.mainContext.insert(alice)
        modelContainer.mainContext.insert(bob)
        modelContainer.mainContext.insert(charlie)
        try modelContainer.mainContext.save()
        trip.travellerIDs.append(contentsOf: [alice.id.uuidString, bob.id.uuidString, charlie.id.uuidString])
        
        // Alice pays for dinner shared by all three
        viewModel.addExpense(
            to: trip,
            title: "Dinner",
            amount: 150.0,
            paidBy: "Alice",
            sharedByMemberIds: [alice.id.uuidString, bob.id.uuidString, charlie.id.uuidString]
        )
        
        // Bob pays for taxi shared by Bob and Charlie
        viewModel.addExpense(
            to: trip,
            title: "Taxi",
            amount: 60.0,
            paidBy: "Bob",
            sharedByMemberIds: [bob.id.uuidString, charlie.id.uuidString]
        )
        
        let shares = viewModel.calculateTravellerShares(for: trip, travellers: [alice, bob, charlie])
        
        let aliceShare = shares.first { $0.traveller.name == "Alice" }
        #expect(aliceShare?.share == 50.0) // 150/3
        #expect(aliceShare?.paid == 150.0)
        #expect(aliceShare?.balance == 100.0) // Owed 100
        
        let bobShare = shares.first { $0.traveller.name == "Bob" }
        #expect(bobShare?.share == 80.0) // 150/3 + 60/2 = 50 + 30
        #expect(bobShare?.paid == 60.0)
        #expect(bobShare?.balance == -20.0) // Owes 20
        
        let charlieShare = shares.first { $0.traveller.name == "Charlie" }
        #expect(charlieShare?.share == 80.0) // 150/3 + 60/2 = 50 + 30
        #expect(charlieShare?.paid == 0.0)
        #expect(charlieShare?.balance == -80.0) // Owes 80
    }
    
    // MARK: - Currency Operations Tests
    
    @Test("Get Default Currency - should return locale currency")
    func testGetDefaultCurrency() async throws {
        let currency = viewModel.getDefaultCurrency()
        
        #expect(!currency.isEmpty)
        // Currency should be valid ISO code (3 letters)
        #expect(currency.count == 3)
    }
    
    @Test("Get Expenses By Currency - should group by currency")
    func testGetExpensesByCurrency() async throws {
        viewModel.addExpense(to: trip, title: "Hotel USD", amount: 100.0, currency: "USD")
        viewModel.addExpense(to: trip, title: "Food USD", amount: 50.0, currency: "USD")
        viewModel.addExpense(to: trip, title: "Hotel EUR", amount: 80.0, currency: "EUR")
        
        let byCurrency = viewModel.getExpensesByCurrency(for: trip)
        
        #expect(byCurrency["USD"]?.count == 2)
        #expect(byCurrency["EUR"]?.count == 1)
    }
    
    // MARK: - Validation Tests
    
    @Test("Validate Expense - valid inputs")
    func testValidateExpenseValid() async throws {
        #expect(viewModel.validateExpense(title: "Hotel", amount: "100.50") == true)
        #expect(viewModel.validateExpense(title: "Food", amount: "50") == true)
    }
    
    @Test("Validate Expense - invalid inputs")
    func testValidateExpenseInvalid() async throws {
        #expect(viewModel.validateExpense(title: "", amount: "100") == false)
        #expect(viewModel.validateExpense(title: "Hotel", amount: "") == false)
        #expect(viewModel.validateExpense(title: "Hotel", amount: "abc") == false)
        #expect(viewModel.validateExpense(title: "", amount: "") == false)
    }
    
    @Test("Validate Amount - valid amounts")
    func testValidateAmountValid() async throws {
        #expect(viewModel.validateAmount("100") == 100.0)
        #expect(viewModel.validateAmount("50.75") == 50.75)
        #expect(viewModel.validateAmount("0") == 0.0)
    }
    
    @Test("Validate Amount - invalid amounts")
    func testValidateAmountInvalid() async throws {
        #expect(viewModel.validateAmount("abc") == nil)
        #expect(viewModel.validateAmount("") == nil)
        #expect(viewModel.validateAmount("12.34.56") == nil)
    }
}

