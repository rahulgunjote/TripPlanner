import Foundation
import SwiftData

@MainActor
@Observable
class ExpenseViewModel {
    private var modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // MARK: - Expense CRUD Operations
    @discardableResult
    func addExpense(
        to trip: Trip,
        title: String,
        amount: Double,
        currency: String = "USD",
        category: ExpenseCategory = .other,
        date: Date = Date(),
        notes: String = "",
        paidBy: String = "",
        sharedByMemberIds: [String] = []
    ) -> Expense {
        let expense = Expense(
            title: title,
            amount: amount,
            currency: currency,
            category: category,
            date: date,
            notes: notes,
            paidBy: paidBy,
            sharedByMemberIds: sharedByMemberIds
        )
        trip.expenses.append(expense)
        try? modelContext.save()
        return expense
    }
    
    func updateExpense(
        expense: Expense,
        title: String? = nil,
        amount: Double? = nil,
        currency: String? = nil,
        category: ExpenseCategory? = nil,
        date: Date? = nil,
        notes: String? = nil,
        paidBy: String? = nil,
        sharedByMemberIds: [String]? = nil
    ) {
        if let title = title { expense.title = title }
        if let amount = amount { expense.amount = amount }
        if let currency = currency { expense.currency = currency }
        if let category = category { expense.category = category }
        if let date = date { expense.date = date }
        if let notes = notes { expense.notes = notes }
        if let paidBy = paidBy { expense.paidBy = paidBy }
        if let sharedByMemberIds = sharedByMemberIds { expense.sharedByMemberIds = sharedByMemberIds }
        try? modelContext.save()
    }
    
    func deleteExpense(from trip: Trip, expense: Expense) {
        if let index = trip.expenses.firstIndex(where: { $0.id == expense.id }) {
            trip.expenses.remove(at: index)
            modelContext.delete(expense)
            try? modelContext.save()
        }
    }
    
    // MARK: - Expense Calculations
    
    func calculateTotalExpenses(for trip: Trip) -> Double {
        trip.expenses.reduce(0) { $0 + $1.amount }
    }
    
    func calculateExpensesByCategory(for trip: Trip) -> [ExpenseCategory: Double] {
        var result: [ExpenseCategory: Double] = [:]
        for expense in trip.expenses {
            result[expense.category, default: 0] += expense.amount
        }
        return result
    }
    
    func getSortedExpenses(for trip: Trip) -> [Expense] {
        trip.expenses.sorted { $0.date > $1.date }
    }
    
    // MARK: - Member Share Calculations
    
    struct TravellerExpenseShare {
        let traveller: Traveller
        let share: Double      // How much they should pay
        let paid: Double       // How much they actually paid
        let balance: Double    // Difference (positive = owed to them, negative = they owe)
    }
    
    func calculateTravellerShares(for trip: Trip, travellers: [Traveller]) -> [TravellerExpenseShare] {
        var shares: [TravellerExpenseShare] = []
        
        for traveller in travellers {
            let travellerId = traveller.id.uuidString
            
            // Calculate how much this traveller should pay (their share)
            let travellerShare = calculateTravellerShare(travellerId: travellerId, expenses: trip.expenses)
            
            // Calculate how much this traveller paid
            let travellerPaid = calculateTravellerPaidAmount(travellerName: traveller.name, expenses: trip.expenses)
            
            // Calculate balance (positive = owed to them, negative = they owe)
            let balance = travellerPaid - travellerShare
            
            shares.append(TravellerExpenseShare(
                traveller: traveller,
                share: travellerShare,
                paid: travellerPaid,
                balance: balance
            ))
        }
        
        return shares.sorted { $0.traveller.name < $1.traveller.name }
    }
    
    func calculateTravellerShare(travellerId: String, expenses: [Expense]) -> Double {
        var share: Double = 0
        
        for expense in expenses {
            if expense.sharedByMemberIds.contains(travellerId) {
                let shareCount = max(expense.sharedByMemberIds.count, 1)
                share += expense.amount / Double(shareCount)
            }
        }
        
        return share
    }
    
    func calculateTravellerPaidAmount(travellerName: String, expenses: [Expense]) -> Double {
        expenses
            .filter { $0.paidBy == travellerName }
            .reduce(0) { $0 + $1.amount }
    }
    
    // Backwards compatibility
    func calculateMemberShare(memberId: String, expenses: [Expense]) -> Double {
        calculateTravellerShare(travellerId: memberId, expenses: expenses)
    }
    
    func calculateMemberPaidAmount(memberName: String, expenses: [Expense]) -> Double {
        calculateTravellerPaidAmount(travellerName: memberName, expenses: expenses)
    }
    
    // MARK: - Currency Operations
    
    func getDefaultCurrency() -> String {
        Locale.current.currency?.identifier ?? "USD"
    }
    
    func getExpensesByCurrency(for trip: Trip) -> [String: [Expense]] {
        Dictionary(grouping: trip.expenses) { $0.currency }
    }
    
    // MARK: - Validation
    
    func validateExpense(title: String, amount: String) -> Bool {
        !title.isEmpty && !amount.isEmpty && Double(amount) != nil
    }
    
    func validateAmount(_ amount: String) -> Double? {
        Double(amount)
    }
}

