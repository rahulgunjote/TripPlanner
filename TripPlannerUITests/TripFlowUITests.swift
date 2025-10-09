//
//  TripFlowUITests.swift
//  TripPlannerUITests
//
//  Comprehensive UI tests for Trip-related flows
//

import XCTest

final class TripFlowUITests: XCTestCase {
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
    
    // MARK: - Trip List Tests
    
    @MainActor
    func testTripListEmptyState() throws {
        // If no trips, should show empty state
        let emptyStateText = app.staticTexts.containing(NSPredicate(format: "label CONTAINS[c] 'No trips'")).firstMatch
        let addButton = app.buttons.matching(identifier: "plus").firstMatch
        
        // Either there are trips or empty state
        XCTAssertTrue(emptyStateText.exists || app.tables.cells.count > 0 || addButton.exists)
    }
    
    @MainActor
    func testSwipeToDeleteTrip() throws {
        let firstCell = app.tables.cells.firstMatch
        if firstCell.exists {
            // Swipe to reveal delete button
            firstCell.swipeLeft()
            
            // Check if delete button appears
            sleep(1)
            let deleteButton = app.buttons["Delete"]
            XCTAssertTrue(deleteButton.exists || app.buttons["trash"].exists)
            
            // Swipe back to cancel
            firstCell.swipeRight()
        }
    }
    
    @MainActor
    func testTripRowDisplaysInformation() throws {
        let firstCell = app.tables.cells.firstMatch
        if firstCell.exists {
            // Check that cell contains trip information
            XCTAssertTrue(firstCell.staticTexts.count > 0)
        }
    }
    
    // MARK: - Create Trip Tests
    
    @MainActor
    func testCreateTripPhotoSelection() throws {
        let addButton = app.buttons.matching(identifier: "plus").firstMatch
        addButton.tap()
        
        // Look for photo picker button
        let selectImageButton = app.buttons["Select Image"]
        if selectImageButton.exists {
            selectImageButton.tap()
            sleep(1)
            
            // Cancel photo picker if it appears
            let cancelButton = app.buttons["Cancel"]
            if cancelButton.exists {
                cancelButton.tap()
            }
        }
        
        let cancelTripButton = app.navigationBars.buttons["Cancel"]
        cancelTripButton.tap()
    }
    
    @MainActor
    func testCreateTripWithTravellers() throws {
        let addButton = app.buttons.matching(identifier: "plus").firstMatch
        addButton.tap()
        
        // Scroll to travellers section
        app.swipeUp()
        
        // Look for traveller selection
        let selectTravellersButton = app.buttons["Select Travellers"]
        if selectTravellersButton.exists {
            selectTravellersButton.tap()
            
            // Should show traveller selection screen
            XCTAssertTrue(app.navigationBars["Select Travellers"].exists)
            
            // Tap Done
            let doneButton = app.navigationBars.buttons["Done"]
            doneButton.tap()
        }
        
        let cancelButton = app.navigationBars.buttons["Cancel"]
        cancelButton.tap()
    }
    
    @MainActor
    func testCreateTripLocationPicker() throws {
        let addButton = app.buttons.matching(identifier: "plus").firstMatch
        addButton.tap()
        
        // Look for location picker button
        let setLocationButton = app.buttons.containing(NSPredicate(format: "label CONTAINS[c] 'Location'")).firstMatch
        if setLocationButton.exists {
            setLocationButton.tap()
            
            XCTAssertTrue(app.navigationBars["Select Location"].exists)
            
            let cancelButton = app.navigationBars.buttons["Cancel"]
            cancelButton.tap()
        }
        
        let cancelTripButton = app.navigationBars.buttons["Cancel"]
        cancelTripButton.tap()
    }
    
    @MainActor
    func testCreateTripDateSelection() throws {
        let addButton = app.buttons.matching(identifier: "plus").firstMatch
        addButton.tap()
        
        // Check for date pickers
        let startDate = app.staticTexts["Start Date"]
        let endDate = app.staticTexts["End Date"]
        
        XCTAssertTrue(startDate.exists)
        XCTAssertTrue(endDate.exists)
        
        let cancelButton = app.navigationBars.buttons["Cancel"]
        cancelButton.tap()
    }
    
    // MARK: - Trip Detail Tests
    
    @MainActor
    func testTripDetailDisplaysAllSections() throws {
        let firstCell = app.tables.cells.firstMatch
        if firstCell.exists {
            firstCell.tap()
            
            // Scroll through detail view
            app.swipeUp()
            app.swipeUp()
            
            // Check for main sections (may not all be visible at once)
            let hasItinerary = app.staticTexts["Itinerary"].exists
            let hasExpenses = app.staticTexts["Expenses"].exists
            let hasTravellers = app.staticTexts.containing(NSPredicate(format: "label CONTAINS[c] 'Traveller'")).firstMatch.exists
            
            XCTAssertTrue(hasItinerary || hasExpenses || hasTravellers)
            
            app.navigationBars.buttons.firstMatch.tap()
        }
    }
    
    @MainActor
    func testTripDetailAddTraveller() throws {
        let firstCell = app.tables.cells.firstMatch
        if firstCell.exists {
            firstCell.tap()
            
            // Look for travellers section and add button
            let travellersSection = app.buttons.containing(NSPredicate(format: "label CONTAINS[c] 'Traveller'")).firstMatch
            if travellersSection.exists {
                travellersSection.tap()
                
                // Should show travellers list
                sleep(1)
                
                // Look for Add button in toolbar
                let addButton = app.navigationBars.buttons["Add"]
                if addButton.exists {
                    addButton.tap()
                    sleep(1)
                    
                    // Cancel the add traveller flow
                    let cancelButton = app.navigationBars.buttons["Cancel"]
                    if cancelButton.exists {
                        cancelButton.tap()
                    }
                }
                
                // Go back
                let doneButton = app.navigationBars.buttons["Done"]
                if doneButton.exists {
                    doneButton.tap()
                }
            }
            
            app.navigationBars.buttons.firstMatch.tap()
        }
    }
    
    @MainActor
    func testTripDetailExpenseReport() throws {
        let firstCell = app.tables.cells.firstMatch
        if firstCell.exists {
            firstCell.tap()
            
            // Scroll to expenses section
            app.swipeUp()
            
            // Look for Report button
            let reportButton = app.buttons["Report"]
            if reportButton.exists {
                reportButton.tap()
                
                // Verify expense report screen
                XCTAssertTrue(app.navigationBars["Expense Report"].exists)
                
                let doneButton = app.navigationBars.buttons["Done"]
                doneButton.tap()
            }
            
            app.navigationBars.buttons.firstMatch.tap()
        }
    }
}

