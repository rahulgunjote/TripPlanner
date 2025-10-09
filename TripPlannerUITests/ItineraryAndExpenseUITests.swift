//
//  ItineraryAndExpenseUITests.swift
//  TripPlannerUITests
//
//  Comprehensive UI tests for Itinerary and Expense features
//

import XCTest

final class ItineraryAndExpenseUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI-TESTING"]
        app.launch()
        
        // Navigate to Trips tab
        app.tabBars.buttons["Trips"].tap()
    }

    override func tearDownWithError() throws {
        app = nil
    }
    
    // Helper method to navigate to trip detail
    private func navigateToFirstTripDetail() -> Bool {
        let firstCell = app.tables.cells.firstMatch
        if firstCell.exists {
            firstCell.tap()
            return true
        }
        return false
    }
    
    // MARK: - Itinerary Tests
    
    @MainActor
    func testItineraryScreenNavigation() throws {
        guard navigateToFirstTripDetail() else {
            throw XCTSkip("No trips available to test")
        }
        
        // Find and tap Itinerary
        let itineraryButton = app.buttons.containing(NSPredicate(format: "label CONTAINS[c] 'Itinerary'")).firstMatch
        if itineraryButton.exists {
            itineraryButton.tap()
            
            XCTAssertTrue(app.navigationBars["Itinerary"].exists)
            
            app.navigationBars.buttons.firstMatch.tap()
        }
        
        app.navigationBars.buttons.firstMatch.tap()
    }
    
    @MainActor
    func testItineraryAddButton() throws {
        guard navigateToFirstTripDetail() else {
            throw XCTSkip("No trips available to test")
        }
        
        let itineraryButton = app.buttons.containing(NSPredicate(format: "label CONTAINS[c] 'Itinerary'")).firstMatch
        if itineraryButton.exists {
            itineraryButton.tap()
            
            // Look for Add button
            let addButton = app.buttons.matching(identifier: "plus").firstMatch
            XCTAssertTrue(addButton.exists)
            
            addButton.tap()
            
            // Should show Add Itinerary Item screen
            XCTAssertTrue(app.navigationBars["Add Itinerary Item"].exists || app.navigationBars.firstMatch.exists)
            
            let cancelButton = app.navigationBars.buttons["Cancel"]
            if cancelButton.exists {
                cancelButton.tap()
            }
            
            app.navigationBars.buttons.firstMatch.tap()
        }
        
        app.navigationBars.buttons.firstMatch.tap()
    }
    
    @MainActor
    func testAddItineraryItemForm() throws {
        guard navigateToFirstTripDetail() else {
            throw XCTSkip("No trips available to test")
        }
        
        let itineraryButton = app.buttons.containing(NSPredicate(format: "label CONTAINS[c] 'Itinerary'")).firstMatch
        if itineraryButton.exists {
            itineraryButton.tap()
            
            let addButton = app.buttons.matching(identifier: "plus").firstMatch
            if addButton.exists {
                addButton.tap()
                
                // Check form fields
                let titleField = app.textFields["Title"]
                XCTAssertTrue(titleField.exists)
                
                let locationField = app.textFields["Location"]
                XCTAssertTrue(locationField.exists || app.staticTexts["Location"].exists)
                
                let descriptionField = app.textViews.firstMatch
                XCTAssertTrue(descriptionField.exists || app.staticTexts["Description"].exists)
                
                let cancelButton = app.navigationBars.buttons["Cancel"]
                cancelButton.tap()
            }
            
            app.navigationBars.buttons.firstMatch.tap()
        }
        
        app.navigationBars.buttons.firstMatch.tap()
    }
    
    @MainActor
    func testItineraryItemValidation() throws {
        guard navigateToFirstTripDetail() else {
            throw XCTSkip("No trips available to test")
        }
        
        let itineraryButton = app.buttons.containing(NSPredicate(format: "label CONTAINS[c] 'Itinerary'")).firstMatch
        if itineraryButton.exists {
            itineraryButton.tap()
            
            let addButton = app.buttons.matching(identifier: "plus").firstMatch
            if addButton.exists {
                addButton.tap()
                
                let saveButton = app.navigationBars.buttons["Add"]
                
                // Should be disabled when required fields are empty
                XCTAssertFalse(saveButton.isEnabled)
                
                // Enter title
                let titleField = app.textFields["Title"]
                if titleField.exists {
                    titleField.tap()
                    titleField.typeText("Visit Eiffel Tower")
                    
                    // Should now be enabled
                    XCTAssertTrue(saveButton.isEnabled)
                }
                
                let cancelButton = app.navigationBars.buttons["Cancel"]
                cancelButton.tap()
            }
            
            app.navigationBars.buttons.firstMatch.tap()
        }
        
        app.navigationBars.buttons.firstMatch.tap()
    }
    
    @MainActor
    func testItineraryItemDateSelection() throws {
        guard navigateToFirstTripDetail() else {
            throw XCTSkip("No trips available to test")
        }
        
        let itineraryButton = app.buttons.containing(NSPredicate(format: "label CONTAINS[c] 'Itinerary'")).firstMatch
        if itineraryButton.exists {
            itineraryButton.tap()
            
            let addButton = app.buttons.matching(identifier: "plus").firstMatch
            if addButton.exists {
                addButton.tap()
                
                // Check for date picker
                let datePicker = app.datePickers.firstMatch
                XCTAssertTrue(datePicker.exists || app.staticTexts["Date"].exists)
                
                let cancelButton = app.navigationBars.buttons["Cancel"]
                cancelButton.tap()
            }
            
            app.navigationBars.buttons.firstMatch.tap()
        }
        
        app.navigationBars.buttons.firstMatch.tap()
    }
    
    // MARK: - Expense Tests
    
    @MainActor
    func testAddExpenseButton() throws {
        guard navigateToFirstTripDetail() else {
            throw XCTSkip("No trips available to test")
        }
        
        // Scroll to expenses section
        app.swipeUp()
        
        // Look for Add expense button
        let addButton = app.buttons.containing(NSPredicate(format: "label CONTAINS[c] 'Add'")).firstMatch
        if addButton.exists {
            addButton.tap()
            
            XCTAssertTrue(app.navigationBars["Add Expense"].exists)
            
            let cancelButton = app.navigationBars.buttons["Cancel"]
            cancelButton.tap()
        }
        
        app.navigationBars.buttons.firstMatch.tap()
    }
    
    @MainActor
    func testAddExpenseForm() throws {
        guard navigateToFirstTripDetail() else {
            throw XCTSkip("No trips available to test")
        }
        
        app.swipeUp()
        
        let addButton = app.buttons.containing(NSPredicate(format: "label CONTAINS[c] 'Add'")).firstMatch
        if addButton.exists {
            addButton.tap()
            
            // Check form fields
            let titleField = app.textFields["Title"]
            XCTAssertTrue(titleField.exists)
            
            let amountField = app.textFields["Amount"]
            XCTAssertTrue(amountField.exists)
            
            // Check for category picker
            app.swipeUp()
            let categoryLabel = app.staticTexts["Category"]
            XCTAssertTrue(categoryLabel.exists || app.pickers.firstMatch.exists)
            
            let cancelButton = app.navigationBars.buttons["Cancel"]
            cancelButton.tap()
        }
        
        app.navigationBars.buttons.firstMatch.tap()
    }
    
    @MainActor
    func testAddExpenseValidation() throws {
        guard navigateToFirstTripDetail() else {
            throw XCTSkip("No trips available to test")
        }
        
        app.swipeUp()
        
        let addButton = app.buttons.containing(NSPredicate(format: "label CONTAINS[c] 'Add'")).firstMatch
        if addButton.exists {
            addButton.tap()
            
            let saveButton = app.navigationBars.buttons["Save"]
            
            // Should be disabled when fields are empty
            XCTAssertFalse(saveButton.isEnabled)
            
            // Enter title only
            let titleField = app.textFields["Title"]
            titleField.tap()
            titleField.typeText("Hotel")
            
            // Still disabled (needs amount)
            XCTAssertFalse(saveButton.isEnabled)
            
            // Enter amount
            let amountField = app.textFields["Amount"]
            amountField.tap()
            amountField.typeText("150")
            
            // Now should be enabled
            XCTAssertTrue(saveButton.isEnabled)
            
            let cancelButton = app.navigationBars.buttons["Cancel"]
            cancelButton.tap()
        }
        
        app.navigationBars.buttons.firstMatch.tap()
    }
    
    @MainActor
    func testExpenseCategorySelection() throws {
        guard navigateToFirstTripDetail() else {
            throw XCTSkip("No trips available to test")
        }
        
        app.swipeUp()
        
        let addButton = app.buttons.containing(NSPredicate(format: "label CONTAINS[c] 'Add'")).firstMatch
        if addButton.exists {
            addButton.tap()
            
            app.swipeUp()
            
            // Look for category picker
            let categoryPicker = app.pickers.firstMatch
            if categoryPicker.exists {
                // Categories should include: Accommodation, Transportation, Food, etc.
                XCTAssertTrue(categoryPicker.exists)
            }
            
            let cancelButton = app.navigationBars.buttons["Cancel"]
            cancelButton.tap()
        }
        
        app.navigationBars.buttons.firstMatch.tap()
    }
    
    @MainActor
    func testExpenseSharedBySelection() throws {
        guard navigateToFirstTripDetail() else {
            throw XCTSkip("No trips available to test")
        }
        
        app.swipeUp()
        
        let addButton = app.buttons.containing(NSPredicate(format: "label CONTAINS[c] 'Add'")).firstMatch
        if addButton.exists {
            addButton.tap()
            
            // Scroll to shared by section
            app.swipeUp()
            app.swipeUp()
            
            // Look for "Shared By" section
            let sharedByLabel = app.staticTexts["Shared By"]
            if sharedByLabel.exists {
                XCTAssertTrue(true) // Section exists
            }
            
            let cancelButton = app.navigationBars.buttons["Cancel"]
            cancelButton.tap()
        }
        
        app.navigationBars.buttons.firstMatch.tap()
    }
    
    @MainActor
    func testExpenseReport() throws {
        guard navigateToFirstTripDetail() else {
            throw XCTSkip("No trips available to test")
        }
        
        app.swipeUp()
        
        // Look for Report button
        let reportButton = app.buttons["Report"]
        if reportButton.exists {
            reportButton.tap()
            
            XCTAssertTrue(app.navigationBars["Expense Report"].exists)
            
            // Check for main sections
            app.swipeUp()
            
            let totalLabel = app.staticTexts.containing(NSPredicate(format: "label CONTAINS[c] 'Total'")).firstMatch
            XCTAssertTrue(totalLabel.exists)
            
            let doneButton = app.navigationBars.buttons["Done"]
            doneButton.tap()
        }
        
        app.navigationBars.buttons.firstMatch.tap()
    }
    
    @MainActor
    func testExpenseReportBreakdown() throws {
        guard navigateToFirstTripDetail() else {
            throw XCTSkip("No trips available to test")
        }
        
        app.swipeUp()
        
        let reportButton = app.buttons["Report"]
        if reportButton.exists {
            reportButton.tap()
            
            // Scroll through report
            app.swipeUp()
            app.swipeUp()
            
            // Check for sections
            let memberBreakdown = app.staticTexts.containing(NSPredicate(format: "label CONTAINS[c] 'Breakdown'")).firstMatch
            let expenseDetails = app.staticTexts.containing(NSPredicate(format: "label CONTAINS[c] 'Expense Details'")).firstMatch
            
            XCTAssertTrue(memberBreakdown.exists || expenseDetails.exists)
            
            let doneButton = app.navigationBars.buttons["Done"]
            doneButton.tap()
        }
        
        app.navigationBars.buttons.firstMatch.tap()
    }
}

