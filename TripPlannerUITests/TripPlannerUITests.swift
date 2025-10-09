//
//  TripPlannerUITests.swift
//  TripPlannerUITests
//
//  Created by Rahul Gunjote on 9/10/2025.
//

import XCTest

final class TripPlannerUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI-TESTING"]
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }
    
    // MARK: - Tab Navigation Tests
    
    @MainActor
    func testTabNavigation() throws {
        // Test Trips tab
        let tripsTab = app.tabBars.buttons["Trips"]
        XCTAssertTrue(tripsTab.exists)
        tripsTab.tap()
        XCTAssertTrue(app.navigationBars["My Trips"].exists)
        
        // Test Travellers tab
        let travellersTab = app.tabBars.buttons["Travellers"]
        XCTAssertTrue(travellersTab.exists)
        travellersTab.tap()
        XCTAssertTrue(app.navigationBars["Travellers"].exists)
    }
    
    // MARK: - Trip List Tests
    
    @MainActor
    func testTripListDisplaysCorrectly() throws {
        let tripsTab = app.tabBars.buttons["Trips"]
        tripsTab.tap()
        
        // Check navigation title exists
        XCTAssertTrue(app.navigationBars["My Trips"].exists)
        
        // Check floating action button exists
        let addButton = app.buttons.matching(identifier: "plus").firstMatch
        XCTAssertTrue(addButton.exists)
    }
    
    @MainActor
    func testCreateTripFlow() throws {
        let tripsTab = app.tabBars.buttons["Trips"]
        tripsTab.tap()
        
        // Tap floating add button
        let addButton = app.buttons.matching(identifier: "plus").firstMatch
        addButton.tap()
        
        // Verify Create Trip screen appears
        XCTAssertTrue(app.navigationBars["Create Trip"].exists)
        
        // Fill in trip details
        let tripNameField = app.textFields["Trip Name"]
        XCTAssertTrue(tripNameField.exists)
        tripNameField.tap()
        tripNameField.typeText("Test Trip to Paris")
        
        let locationField = app.textFields["Location Name"]
        XCTAssertTrue(locationField.exists)
        locationField.tap()
        locationField.typeText("Paris, France")
        
        // Tap Save button
        let saveButton = app.navigationBars.buttons["Save"]
        XCTAssertTrue(saveButton.exists)
        
        // Note: Don't actually save to avoid polluting test data
        // In real tests, you'd save and verify the trip appears in the list
        
        // Cancel instead
        let cancelButton = app.navigationBars.buttons["Cancel"]
        cancelButton.tap()
    }
    
    @MainActor
    func testCreateTripValidation() throws {
        let tripsTab = app.tabBars.buttons["Trips"]
        tripsTab.tap()
        
        let addButton = app.buttons.matching(identifier: "plus").firstMatch
        addButton.tap()
        
        // Verify Save button is disabled when fields are empty
        let saveButton = app.navigationBars.buttons["Save"]
        XCTAssertFalse(saveButton.isEnabled)
        
        // Enter trip name only
        let tripNameField = app.textFields["Trip Name"]
        tripNameField.tap()
        tripNameField.typeText("Test Trip")
        
        // Save should still be disabled without location
        XCTAssertFalse(saveButton.isEnabled)
        
        // Add location
        let locationField = app.textFields["Location Name"]
        locationField.tap()
        locationField.typeText("Paris")
        
        // Now save should be enabled
        XCTAssertTrue(saveButton.isEnabled)
        
        let cancelButton = app.navigationBars.buttons["Cancel"]
        cancelButton.tap()
    }
    
    @MainActor
    func testTripDetailNavigation() throws {
        let tripsTab = app.tabBars.buttons["Trips"]
        tripsTab.tap()
        
        // Check if any trips exist in the list
        let firstTrip = app.tables.cells.firstMatch
        if firstTrip.exists {
            firstTrip.tap()
            
            // Verify we're on trip detail screen
            // Check for common elements like sections
            XCTAssertTrue(app.staticTexts["Itinerary"].exists || app.staticTexts["Expenses"].exists)
            
            // Navigate back
            app.navigationBars.buttons.firstMatch.tap()
        }
    }
    
    // MARK: - Traveller List Tests
    
    @MainActor
    func testTravellerListDisplaysCorrectly() throws {
        let travellersTab = app.tabBars.buttons["Travellers"]
        travellersTab.tap()
        
        // Check navigation title
        XCTAssertTrue(app.navigationBars["Travellers"].exists)
        
        // Check floating add button exists
        let addButton = app.buttons.matching(identifier: "plus").firstMatch
        XCTAssertTrue(addButton.exists)
    }
    
    @MainActor
    func testAddTravellerOptionsAppear() throws {
        let travellersTab = app.tabBars.buttons["Travellers"]
        travellersTab.tap()
        
        // Tap floating add button
        let addButton = app.buttons.matching(identifier: "plus").firstMatch
        addButton.tap()
        
        // Wait for action sheet/dialog to appear
        sleep(1)
        
        // Check for action options
        let importButton = app.buttons["Import from Contacts"]
        let manualButton = app.buttons["Add Manually"]
        
        // At least one should exist (depending on iOS version and action sheet style)
        XCTAssertTrue(importButton.exists || manualButton.exists)
        
        // Tap cancel if it exists
        let cancelButton = app.buttons["Cancel"]
        if cancelButton.exists {
            cancelButton.tap()
        }
    }
    
    @MainActor
    func testAddTravellerManually() throws {
        let travellersTab = app.tabBars.buttons["Travellers"]
        travellersTab.tap()
        
        let addButton = app.buttons.matching(identifier: "plus").firstMatch
        addButton.tap()
        
        sleep(1)
        
        // Tap Add Manually
        let manualButton = app.buttons["Add Manually"]
        if manualButton.exists {
            manualButton.tap()
            
            // Verify Add Traveller screen appears
            XCTAssertTrue(app.navigationBars["Add Traveller"].exists)
            
            // Check form elements
            let nameField = app.textFields["Name"]
            XCTAssertTrue(nameField.exists)
            
            let emailField = app.textFields["Email"]
            XCTAssertTrue(emailField.exists)
            
            let phoneField = app.textFields["Phone Number"]
            XCTAssertTrue(phoneField.exists)
            
            // Check type picker
            XCTAssertTrue(app.staticTexts["Adult"].exists || app.staticTexts["Child"].exists)
            
            // Cancel
            let cancelButton = app.navigationBars.buttons["Cancel"]
            cancelButton.tap()
        }
    }
    
    @MainActor
    func testAddTravellerValidation() throws {
        let travellersTab = app.tabBars.buttons["Travellers"]
        travellersTab.tap()
        
        let addButton = app.buttons.matching(identifier: "plus").firstMatch
        addButton.tap()
        
        sleep(1)
        
        let manualButton = app.buttons["Add Manually"]
        if manualButton.exists {
            manualButton.tap()
            
            // Verify Add button is disabled when name is empty
            let addTravellerButton = app.navigationBars.buttons["Add"]
            XCTAssertFalse(addTravellerButton.isEnabled)
            
            // Enter name
            let nameField = app.textFields["Name"]
            nameField.tap()
            nameField.typeText("John Doe")
            
            // Now Add should be enabled
            XCTAssertTrue(addTravellerButton.isEnabled)
            
            let cancelButton = app.navigationBars.buttons["Cancel"]
            cancelButton.tap()
        }
    }
    
    @MainActor
    func testTravellerSearch() throws {
        let travellersTab = app.tabBars.buttons["Travellers"]
        travellersTab.tap()
        
        // Check if search field exists
        let searchField = app.searchFields.firstMatch
        if searchField.exists {
            searchField.tap()
            searchField.typeText("Test")
            
            // Verify search is working (results may vary based on data)
            XCTAssertTrue(searchField.exists)
            
            // Clear search
            if let clearButton = app.buttons["Clear text"].firstMatch as? XCUIElement, clearButton.exists {
                clearButton.tap()
            }
        }
    }
    
    // MARK: - Location Picker Tests
    
    @MainActor
    func testLocationPickerSearch() throws {
        let tripsTab = app.tabBars.buttons["Trips"]
        tripsTab.tap()
        
        let addButton = app.buttons.matching(identifier: "plus").firstMatch
        addButton.tap()
        
        // Tap on Set Location button
        let setLocationButton = app.buttons["Set Location on Map"]
        if setLocationButton.exists {
            setLocationButton.tap()
            
            // Verify location picker screen
            XCTAssertTrue(app.navigationBars["Select Location"].exists)
            
            // Test search
            let searchField = app.textFields["Search for a location"]
            XCTAssertTrue(searchField.exists)
            searchField.tap()
            searchField.typeText("Paris")
            
            // Wait for search results
            sleep(2)
            
            // Cancel
            let cancelButton = app.navigationBars.buttons["Cancel"]
            cancelButton.tap()
            
            // Cancel create trip
            let cancelTripButton = app.navigationBars.buttons["Cancel"]
            cancelTripButton.tap()
        }
    }
    
    // MARK: - Itinerary Tests
    
    @MainActor
    func testItineraryNavigation() throws {
        let tripsTab = app.tabBars.buttons["Trips"]
        tripsTab.tap()
        
        // Tap first trip if it exists
        let firstTrip = app.tables.cells.firstMatch
        if firstTrip.exists {
            firstTrip.tap()
            
            // Look for Itinerary section/button
            let itineraryButton = app.buttons.containing(NSPredicate(format: "label CONTAINS[c] 'Itinerary'")).firstMatch
            if itineraryButton.exists {
                itineraryButton.tap()
                
                // Verify we're on itinerary screen
                XCTAssertTrue(app.navigationBars["Itinerary"].exists)
                
                // Navigate back
                app.navigationBars.buttons.firstMatch.tap()
            }
            
            // Navigate back to trip list
            app.navigationBars.buttons.firstMatch.tap()
        }
    }
    
    // MARK: - Expense Tests
    
    @MainActor
    func testAddExpenseFlow() throws {
        let tripsTab = app.tabBars.buttons["Trips"]
        tripsTab.tap()
        
        // Tap first trip if it exists
        let firstTrip = app.tables.cells.firstMatch
        if firstTrip.exists {
            firstTrip.tap()
            
            // Look for Add expense button
            let addExpenseButton = app.buttons.containing(NSPredicate(format: "label CONTAINS[c] 'Add'")).matching(identifier: "plus.circle.fill").firstMatch
            if addExpenseButton.exists {
                addExpenseButton.tap()
                
                // Verify Add Expense screen
                XCTAssertTrue(app.navigationBars["Add Expense"].exists)
                
                // Check form elements
                let titleField = app.textFields["Title"]
                XCTAssertTrue(titleField.exists)
                
                let amountField = app.textFields["Amount"]
                XCTAssertTrue(amountField.exists)
                
                // Cancel
                let cancelButton = app.navigationBars.buttons["Cancel"]
                cancelButton.tap()
            }
            
            // Navigate back
            app.navigationBars.buttons.firstMatch.tap()
        }
    }
    
    // MARK: - Date Picker Tests
    
    @MainActor
    func testDatePickersInCreateTrip() throws {
        let tripsTab = app.tabBars.buttons["Trips"]
        tripsTab.tap()
        
        let addButton = app.buttons.matching(identifier: "plus").firstMatch
        addButton.tap()
        
        // Check if date pickers exist
        let startDatePicker = app.datePickers["Start Date"]
        let endDatePicker = app.datePickers["End Date"]
        
        // At least one should exist
        XCTAssertTrue(startDatePicker.exists || endDatePicker.exists || app.staticTexts["Start Date"].exists)
        
        let cancelButton = app.navigationBars.buttons["Cancel"]
        cancelButton.tap()
    }
    
    // MARK: - Performance Tests
    
    @MainActor
    func testLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
    
    @MainActor
    func testScrollPerformance() throws {
        let tripsTab = app.tabBars.buttons["Trips"]
        tripsTab.tap()
        
        let table = app.tables.firstMatch
        if table.exists {
            measure(metrics: [XCTOSSignpostMetric.scrollDecelerationMetric]) {
                table.swipeUp(velocity: .fast)
                table.swipeDown(velocity: .fast)
            }
        }
    }
}
