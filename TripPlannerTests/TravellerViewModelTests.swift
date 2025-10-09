import Testing
import SwiftData
import Foundation
@testable import TripPlanner

@MainActor
struct TravellerViewModelTests {
    var modelContainer: ModelContainer
    var viewModel: TravellerViewModel
    
    init() async throws {
        let schema = Schema([
            Trip.self,
            Traveller.self,
            ItineraryItem.self,
            Expense.self
        ])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        modelContainer = try ModelContainer(for: schema, configurations: [config])
        viewModel = TravellerViewModel(modelContext: modelContainer.mainContext)
    }
    
    // MARK: - Traveller CRUD Tests
    
    @Test("Create Traveller - should create traveller with all properties")
    func testCreateTraveller() async throws {
        let traveller = viewModel.createTraveller(
            name: "John Doe",
            email: "john@example.com",
            phoneNumber: "123-456-7890",
            travellerType: .adult
        )
        
        #expect(traveller.name == "John Doe")
        #expect(traveller.email == "john@example.com")
        #expect(traveller.phoneNumber == "123-456-7890")
        #expect(traveller.travellerType == .adult)
    }
    
    @Test("Create Child Traveller - should create child traveller")
    func testCreateChildTraveller() async throws {
        let traveller = viewModel.createTraveller(
            name: "Jane Doe",
            travellerType: .child
        )
        
        #expect(traveller.travellerType == .child)
        #expect(traveller.name == "Jane Doe")
    }
    
    @Test("Update Traveller - should update traveller properties")
    func testUpdateTraveller() async throws {
        let traveller = viewModel.createTraveller(
            name: "Original",
            email: "original@example.com"
        )
        
        viewModel.updateTraveller(
            traveller: traveller,
            name: "Updated",
            email: "updated@example.com",
            phoneNumber: "555-1234",
            travellerType: .child
        )
        
        #expect(traveller.name == "Updated")
        #expect(traveller.email == "updated@example.com")
        #expect(traveller.phoneNumber == "555-1234")
        #expect(traveller.travellerType == .child)
    }
    
    @Test("Delete Traveller - should remove traveller")
    func testDeleteTraveller() async throws {
        let traveller = viewModel.createTraveller(name: "John")
        let travellerId = traveller.id
        
        viewModel.deleteTraveller(traveller)
        
        let fetched = viewModel.getTravellerById(travellerId)
        #expect(fetched == nil)
    }
    
    // MARK: - Traveller Queries Tests
    
    @Test("Get All Travellers - should return all travellers")
    func testGetAllTravellersGlobally() async throws {
        viewModel.createTraveller(name: "Traveller 1")
        viewModel.createTraveller(name: "Traveller 2")
        viewModel.createTraveller(name: "Traveller 3")
        
        let travellers = viewModel.getAllTravellersGlobally()
        
        #expect(travellers.count == 3)
    }
    
    @Test("Get Adults - should return only adult travellers")
    func testGetAdultsGlobally() async throws {
        viewModel.createTraveller(name: "Adult 1", travellerType: .adult)
        viewModel.createTraveller(name: "Child 1", travellerType: .child)
        viewModel.createTraveller(name: "Adult 2", travellerType: .adult)
        
        let adults = viewModel.getAdultsGlobally()
        
        #expect(adults.count == 2)
        #expect(adults.allSatisfy { $0.travellerType == .adult })
    }
    
    @Test("Get Children - should return only child travellers")
    func testGetChildrenGlobally() async throws {
        viewModel.createTraveller(name: "Adult 1", travellerType: .adult)
        viewModel.createTraveller(name: "Child 1", travellerType: .child)
        viewModel.createTraveller(name: "Child 2", travellerType: .child)
        
        let children = viewModel.getChildrenGlobally()
        
        #expect(children.count == 2)
        #expect(children.allSatisfy { $0.travellerType == .child })
    }
    
    @Test("Get Traveller By ID - should find existing traveller")
    func testGetTravellerById() async throws {
        let traveller = viewModel.createTraveller(name: "John")
        
        let found = viewModel.getTravellerById(traveller.id)
        
        #expect(found != nil)
        #expect(found?.id == traveller.id)
        #expect(found?.name == "John")
    }
    
    @Test("Get Traveller By ID - should return nil for non-existent ID")
    func testGetTravellerByIdNotFound() async throws {
        viewModel.createTraveller(name: "John")
        
        let found = viewModel.getTravellerById(UUID())
        
        #expect(found == nil)
    }
    
    @Test("Search Travellers - should find travellers by name")
    func testSearchTravellersGlobally() async throws {
        viewModel.createTraveller(name: "John Doe")
        viewModel.createTraveller(name: "Jane Doe")
        viewModel.createTraveller(name: "Bob Smith")
        
        let results = viewModel.searchTravellersGlobally(query: "doe")
        
        #expect(results.count == 2)
        #expect(results.contains(where: { $0.name == "John Doe" }))
        #expect(results.contains(where: { $0.name == "Jane Doe" }))
    }
    
    @Test("Search Travellers - should be case insensitive")
    func testSearchTravellersCaseInsensitive() async throws {
        viewModel.createTraveller(name: "John Doe")
        
        let results = viewModel.searchTravellersGlobally(query: "JOHN")
        
        #expect(results.count == 1)
        #expect(results[0].name == "John Doe")
    }
    
    @Test("Search Travellers - should search in email")
    func testSearchTravellersInEmail() async throws {
        viewModel.createTraveller(name: "John", email: "john@example.com")
        viewModel.createTraveller(name: "Jane", email: "jane@test.com")
        
        let results = viewModel.searchTravellersGlobally(query: "example")
        
        #expect(results.count == 1)
        #expect(results[0].name == "John")
    }
    
    // MARK: - Validation Tests
    
    @Test("Validate Traveller Name - valid names")
    func testValidateTravellerNameValid() async throws {
        #expect(viewModel.validateTravellerName("John Doe") == true)
        #expect(viewModel.validateTravellerName("A") == true)
        #expect(viewModel.validateTravellerName("Name With Spaces") == true)
    }
    
    @Test("Validate Traveller Name - invalid names")
    func testValidateTravellerNameInvalid() async throws {
        #expect(viewModel.validateTravellerName("") == false)
        #expect(viewModel.validateTravellerName("   ") == false)
        #expect(viewModel.validateTravellerName("\n\t") == false)
    }
    
    @Test("Validate Email - valid emails")
    func testValidateEmailValid() async throws {
        #expect(viewModel.validateEmail("john@example.com") == true)
        #expect(viewModel.validateEmail("user.name@domain.co.uk") == true)
        #expect(viewModel.validateEmail("") == true) // Empty is valid (optional)
    }
    
    @Test("Validate Email - invalid emails")
    func testValidateEmailInvalid() async throws {
        #expect(viewModel.validateEmail("invalid") == false)
        #expect(viewModel.validateEmail("@example.com") == false)
        #expect(viewModel.validateEmail("user@") == false)
        #expect(viewModel.validateEmail("user @example.com") == false)
    }
    
    @Test("Validate Phone Number - valid phones")
    func testValidatePhoneNumberValid() async throws {
        #expect(viewModel.validatePhoneNumber("1234567890") == true)
        #expect(viewModel.validatePhoneNumber("123-456-7890") == true)
        #expect(viewModel.validatePhoneNumber("(123) 456-7890") == true)
        #expect(viewModel.validatePhoneNumber("") == true) // Empty is valid (optional)
    }
    
    @Test("Validate Phone Number - invalid phones")
    func testValidatePhoneNumberInvalid() async throws {
        #expect(viewModel.validatePhoneNumber("123") == false)
        #expect(viewModel.validatePhoneNumber("12345") == false)
        #expect(viewModel.validatePhoneNumber("abc") == false)
    }
    
    // MARK: - Additional Validation Edge Cases
    
    @Test("Validate Email - edge cases")
    func testValidateEmailEdgeCases() async throws {
        // Valid edge cases
        #expect(viewModel.validateEmail("test+tag@example.com") == true)
        #expect(viewModel.validateEmail("user_name@example.com") == true)
        #expect(viewModel.validateEmail("user-name@example.com") == true)
        #expect(viewModel.validateEmail("123@example.com") == true)
        
        // Invalid edge cases
        #expect(viewModel.validateEmail("user@") == false)
        #expect(viewModel.validateEmail("@example.com") == false)
        #expect(viewModel.validateEmail("user name@example.com") == false) // Space in email
        #expect(viewModel.validateEmail("user@example") == false) // Missing TLD
        #expect(viewModel.validateEmail("user@@example.com") == false) // Double @
    }
    
    @Test("Validate Phone Number - edge cases with formatting")
    func testValidatePhoneNumberEdgeCasesWithFormatting() async throws {
        // Valid with various formats
        #expect(viewModel.validatePhoneNumber("+1 (123) 456-7890") == true)
        #expect(viewModel.validatePhoneNumber("+44 20 1234 5678") == true)
        #expect(viewModel.validatePhoneNumber("123.456.7890") == true)
        #expect(viewModel.validatePhoneNumber("1234567890123") == true) // More than 10 digits
        
        // Invalid - less than 10 digits
        #expect(viewModel.validatePhoneNumber("123-456-78") == false) // Only 8 digits
        #expect(viewModel.validatePhoneNumber("(123) 456") == false) // Only 6 digits
    }
    
    @Test("Validate Traveller Name - edge cases with whitespace")
    func testValidateTravellerNameEdgeCasesWhitespace() async throws {
        // Should trim and validate
        #expect(viewModel.validateTravellerName("  John Doe  ") == true)
        #expect(viewModel.validateTravellerName("\tJohn Doe\n") == true)
        
        // Only whitespace should be invalid
        #expect(viewModel.validateTravellerName("     ") == false)
        #expect(viewModel.validateTravellerName("\t\n\r") == false)
    }
    
    @Test("Validate Email - special characters")
    func testValidateEmailSpecialCharacters() async throws {
        // Valid special chars in local part
        #expect(viewModel.validateEmail("user.name@example.com") == true)
        #expect(viewModel.validateEmail("user_name@example.com") == true)
        #expect(viewModel.validateEmail("user-name@example.com") == true)
        #expect(viewModel.validateEmail("user+tag@example.com") == true)
        
        // Invalid special chars
        #expect(viewModel.validateEmail("user!name@example.com") == false)
        #expect(viewModel.validateEmail("user#name@example.com") == false)
        #expect(viewModel.validateEmail("user$name@example.com") == false)
    }
    
    @Test("Create Traveller - with invalid email should still create")
    func testCreateTravellerWithInvalidEmailStillCreates() async throws {
        // The ViewModel doesn't validate on creation, that's the UI's job
        // This test ensures the ViewModel accepts any input (UI should validate)
        let traveller = viewModel.createTraveller(
            name: "John Doe",
            email: "invalid-email", // Invalid email
            phoneNumber: "123" // Invalid phone
        )
        
        #expect(traveller.name == "John Doe")
        #expect(traveller.email == "invalid-email")
        #expect(traveller.phoneNumber == "123")
    }
    
    @Test("Validation - comprehensive email test suite")
    func testComprehensiveEmailValidation() async throws {
        // Valid emails
        let validEmails = [
            "",
            "simple@example.com",
            "user.name@example.com",
            "user_name@example.com",
            "user-name@example.com",
            "user+tag@example.com",
            "123456@example.com",
            "test@subdomain.example.com",
            "test@example.co.uk"
        ]
        
        for email in validEmails {
            #expect(viewModel.validateEmail(email) == true, "Expected '\(email)' to be valid")
        }
        
        // Invalid emails
        let invalidEmails = [
            "invalid",
            "@example.com",
            "user@",
            "user @example.com",
            "user@example",
            "user@@example.com",
            "user..name@example.com",
            ".user@example.com",
            "user.@example.com"
        ]
        
        for email in invalidEmails {
            #expect(viewModel.validateEmail(email) == false, "Expected '\(email)' to be invalid")
        }
    }
    
    @Test("Validation - comprehensive phone test suite")
    func testComprehensivePhoneValidation() async throws {
        // Valid phone numbers
        let validPhones = [
            "",
            "1234567890",
            "123-456-7890",
            "(123) 456-7890",
            "+1 (123) 456-7890",
            "+44 20 1234 5678",
            "123.456.7890",
            "1234567890123",
            "+1-800-555-5555"
        ]
        
        for phone in validPhones {
            #expect(viewModel.validatePhoneNumber(phone) == true, "Expected '\(phone)' to be valid")
        }
        
        // Invalid phone numbers
        let invalidPhones = [
            "123",
            "12345",
            "123456789", // Only 9 digits
            "abc",
            "abc-def-ghij",
            "12-34-56"
        ]
        
        for phone in invalidPhones {
            #expect(viewModel.validatePhoneNumber(phone) == false, "Expected '\(phone)' to be invalid")
        }
    }
    
    @Test("Is Duplicate Traveller Name - should detect duplicates")
    func testIsDuplicateTravellerName() async throws {
        viewModel.createTraveller(name: "John Doe")
        
        #expect(viewModel.isDuplicateTravellerName("John Doe") == true)
        #expect(viewModel.isDuplicateTravellerName("john doe") == true) // Case insensitive
        #expect(viewModel.isDuplicateTravellerName("  John Doe  ") == true) // Trimmed
    }
    
    @Test("Is Duplicate Traveller Name - should not detect unique names")
    func testIsDuplicateTravellerNameUnique() async throws {
        viewModel.createTraveller(name: "John Doe")
        
        #expect(viewModel.isDuplicateTravellerName("Jane Doe") == false)
        #expect(viewModel.isDuplicateTravellerName("John") == false)
    }
    
    @Test("Is Duplicate Traveller Name - should exclude specific traveller")
    func testIsDuplicateTravellerNameExcluding() async throws {
        let traveller = viewModel.createTraveller(name: "John Doe")
        
        // Should not detect as duplicate when excluding the same traveller
        #expect(viewModel.isDuplicateTravellerName("John Doe", excluding: traveller.id) == false)
        
        // Should still detect as duplicate for different traveller
        let traveller2 = viewModel.createTraveller(name: "Jane Doe")
        #expect(viewModel.isDuplicateTravellerName("John Doe", excluding: traveller2.id) == true)
    }
    
    // MARK: - Count Tests
    
    @Test("Get Total Travellers Count - should count all travellers")
    func testGetTotalTravellersCount() async throws {
        viewModel.createTraveller(name: "Traveller 1")
        viewModel.createTraveller(name: "Traveller 2")
        viewModel.createTraveller(name: "Traveller 3")
        
        let count = viewModel.getTotalTravellersCount()
        
        #expect(count == 3)
    }
    
    @Test("Get Adults Count - should count adult travellers")
    func testGetAdultsCount() async throws {
        viewModel.createTraveller(name: "Adult 1", travellerType: .adult)
        viewModel.createTraveller(name: "Child 1", travellerType: .child)
        viewModel.createTraveller(name: "Adult 2", travellerType: .adult)
        
        let count = viewModel.getAdultsCount()
        
        #expect(count == 2)
    }
    
    @Test("Get Children Count - should count child travellers")
    func testGetChildrenCount() async throws {
        viewModel.createTraveller(name: "Adult 1", travellerType: .adult)
        viewModel.createTraveller(name: "Child 1", travellerType: .child)
        viewModel.createTraveller(name: "Child 2", travellerType: .child)
        
        let count = viewModel.getChildrenCount()
        
        #expect(count == 2)
    }
}

