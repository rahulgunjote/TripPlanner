import Foundation
import SwiftData

@Model
final class Expense {
    var id: UUID
    var title: String
    var amount: Double
    var currency: String
    var category: ExpenseCategory
    var date: Date
    var notes: String
    var paidBy: String
    var sharedByMemberIds: [String] // Store member IDs who share this expense
    
    init(
        id: UUID = UUID(),
        title: String,
        amount: Double,
        currency: String = "USD",
        category: ExpenseCategory = .other,
        date: Date = Date(),
        notes: String = "",
        paidBy: String = "",
        sharedByMemberIds: [String] = []
    ) {
        self.id = id
        self.title = title
        self.amount = amount
        self.currency = currency
        self.category = category
        self.date = date
        self.notes = notes
        self.paidBy = paidBy
        self.sharedByMemberIds = sharedByMemberIds
    }
}

enum ExpenseCategory: String, Codable, CaseIterable {
    case accommodation = "Accommodation"
    case transportation = "Transportation"
    case food = "Food & Dining"
    case activities = "Activities"
    case shopping = "Shopping"
    case other = "Other"
    
    var icon: String {
        switch self {
        case .accommodation: return "bed.double.fill"
        case .transportation: return "car.fill"
        case .food: return "fork.knife"
        case .activities: return "ticket.fill"
        case .shopping: return "cart.fill"
        case .other: return "ellipsis.circle.fill"
        }
    }
}

