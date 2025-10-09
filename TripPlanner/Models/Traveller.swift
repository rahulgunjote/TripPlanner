import Foundation
import SwiftData

enum TravellerType: String, Codable {
    case adult = "Adult"
    case child = "Child"
}

@Model
final class Traveller {
    var id: UUID
    var name: String
    var email: String
    var phoneNumber: String
    var travellerType: TravellerType
    
    init(
        id: UUID = UUID(),
        name: String,
        email: String = "",
        phoneNumber: String = "",
        travellerType: TravellerType = .adult
    ) {
        self.id = id
        self.name = name
        self.email = email
        self.phoneNumber = phoneNumber
        self.travellerType = travellerType
    }
}

