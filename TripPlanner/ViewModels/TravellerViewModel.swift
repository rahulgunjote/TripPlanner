import Foundation
import SwiftData

@MainActor
@Observable
class TravellerViewModel {
    private var modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // MARK: - Traveller CRUD Operations
    
    func createTraveller(
        name: String,
        email: String = "",
        phoneNumber: String = "",
        travellerType: TravellerType = .adult
    ) -> Traveller {
        let traveller = Traveller(
            name: name,
            email: email,
            phoneNumber: phoneNumber,
            travellerType: travellerType
        )
        modelContext.insert(traveller)
        try? modelContext.save()
        return traveller
    }
    
    func updateTraveller(
        traveller: Traveller,
        name: String? = nil,
        email: String? = nil,
        phoneNumber: String? = nil,
        travellerType: TravellerType? = nil
    ) {
        if let name = name { traveller.name = name }
        if let email = email { traveller.email = email }
        if let phoneNumber = phoneNumber { traveller.phoneNumber = phoneNumber }
        if let travellerType = travellerType { traveller.travellerType = travellerType }
        try? modelContext.save()
    }
    
    func deleteTraveller(_ traveller: Traveller) {
        modelContext.delete(traveller)
        try? modelContext.save()
    }
    
    // MARK: - Global Traveller Queries
    
    func getAllTravellersGlobally() -> [Traveller] {
        let descriptor = FetchDescriptor<Traveller>(sortBy: [SortDescriptor(\.name)])
        return (try? modelContext.fetch(descriptor)) ?? []
    }
    
    func searchTravellersGlobally(query: String) -> [Traveller] {
        let allTravellers = getAllTravellersGlobally()
        guard !query.isEmpty else { return allTravellers }
        
        let lowercasedQuery = query.lowercased()
        return allTravellers.filter { traveller in
            traveller.name.lowercased().contains(lowercasedQuery) ||
            traveller.email.lowercased().contains(lowercasedQuery)
        }
    }
    
    func getAdultsGlobally() -> [Traveller] {
        getAllTravellersGlobally().filter { $0.travellerType == .adult }
    }
    
    func getChildrenGlobally() -> [Traveller] {
        getAllTravellersGlobally().filter { $0.travellerType == .child }
    }
    
    func getTravellerById(_ id: UUID) -> Traveller? {
        let descriptor = FetchDescriptor<Traveller>(
            predicate: #Predicate { $0.id == id }
        )
        return try? modelContext.fetch(descriptor).first
    }
    
    func getTravellerByName(_ name: String) -> Traveller? {
        getAllTravellersGlobally().first { $0.name.lowercased() == name.lowercased() }
    }
    
    // MARK: - Counts
    
    func getTotalTravellersCount() -> Int {
        getAllTravellersGlobally().count
    }
    
    func getAdultsCount() -> Int {
        getAdultsGlobally().count
    }
    
    func getChildrenCount() -> Int {
        getChildrenGlobally().count
    }
    
    // MARK: - Validation
    
    func validateTravellerName(_ name: String) -> Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    func validateEmail(_ email: String) -> Bool {
        if email.isEmpty { return true } // Email is optional
        
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    func validatePhoneNumber(_ phoneNumber: String) -> Bool {
        if phoneNumber.isEmpty { return true } // Phone is optional
        
        // Basic validation - at least 10 digits
        let digits = phoneNumber.filter { $0.isNumber }
        return digits.count >= 10
    }
    
    func isDuplicateTravellerName(_ name: String, excluding travellerId: UUID? = nil) -> Bool {
        let normalizedName = name.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        let allTravellers = getAllTravellersGlobally()
        
        return allTravellers.contains { traveller in
            if let excludeId = travellerId, traveller.id == excludeId {
                return false
            }
            return traveller.name.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) == normalizedName
        }
    }
}

