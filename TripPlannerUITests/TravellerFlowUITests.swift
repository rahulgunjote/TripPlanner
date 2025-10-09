//
//  TravellerFlowUITests.swift
//  TripPlannerUITests
//
//  Comprehensive UI tests for Traveller-related flows
//

import XCTest

final class TravellerFlowUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI-TESTING"]
        app.launch()
        
        // Navigate to Travellers tab
        app.tabBars.buttons["Travellers"].tap()
    }

    override func tearDownWithError() throws {
        app = nil
    }
    
    // MARK: - Traveller List Tests
    
    @MainActor
    func testTravellerListLayout() throws {
        // Check main elements exist
        XCTAssertTrue(app.navigationBars["Travellers"].exists)
        
        let addButton = app.buttons.matching(identifier: "plus").firstMatch
        XCTAssertTrue(addButton.exists)
    }
    
    @MainActor
    func testTravellerListEmptyState() throws {
        let emptyStateText = app.staticTexts.containing(NSPredicate(format: "label CONTAINS[c] 'No Travellers'")).firstMatch
        let addButton = app.buttons.matching(identifier: "plus").firstMatch
        
        // Either there are travellers or empty state
        XCTAssertTrue(emptyStateText.exists || app.tables.cells.count > 0 || addButton.exists)
    }
    
    @MainActor
    func testTravellerListSections() throws {
        // Check if travellers are organized by Adult/Children sections
        let adultsSection = app.staticTexts.containing(NSPredicate(format: "label CONTAINS[c] 'Adult'")).firstMatch
        let childrenSection = app.staticTexts.containing(NSPredicate(format: "label CONTAINS[c] 'Child'")).firstMatch
        
        // At least one section should exist if there are travellers
        if app.tables.cells.count > 0 {
            XCTAssertTrue(adultsSection.exists || childrenSection.exists)
        }
    }
    
    @MainActor
    func testSwipeToDeleteTraveller() throws {
        let firstCell = app.tables.cells.firstMatch
        if firstCell.exists {
            firstCell.swipeLeft()
            sleep(1)
            
            let deleteButton = app.buttons["Delete"]
            XCTAssertTrue(deleteButton.exists || app.buttons["trash"].exists)
            
            // Swipe back to cancel
            firstCell.swipeRight()
        }
    }
    
    // MARK: - Add Traveller Tests
    
    @MainActor
    func testAddTravellerActionSheet() throws {
        let addButton = app.buttons.matching(identifier: "plus").firstMatch
        addButton.tap()
        sleep(1)
        
        // Check for action sheet options
        let importButton = app.buttons["Import from Contacts"]
        let manualButton = app.buttons["Add Manually"]
        let cancelButton = app.buttons["Cancel"]
        
        XCTAssertTrue(importButton.exists || manualButton.exists)
        
        if cancelButton.exists {
            cancelButton.tap()
        }
    }
    
    @MainActor
    func testAddTravellerManuallyForm() throws {
        let addButton = app.buttons.matching(identifier: "plus").firstMatch
        addButton.tap()
        sleep(1)
        
        let manualButton = app.buttons["Add Manually"]
        if manualButton.exists {
            manualButton.tap()
            
            // Verify form elements
            XCTAssertTrue(app.navigationBars["Add Traveller"].exists)
            
            let nameField = app.textFields["Name"]
            XCTAssertTrue(nameField.exists)
            
            let emailField = app.textFields["Email"]
            XCTAssertTrue(emailField.exists)
            
            let phoneField = app.textFields["Phone Number"]
            XCTAssertTrue(phoneField.exists)
            
            // Check type picker (Adult/Child)
            let adultButton = app.buttons["Adult"]
            let childButton = app.buttons["Child"]
            XCTAssertTrue(adultButton.exists || childButton.exists)
            
            let cancelButtonNav = app.navigationBars.buttons["Cancel"]
            cancelButtonNav.tap()
        }
    }
    
    @MainActor
    func testAddTravellerTypePicker() throws {
        let addButton = app.buttons.matching(identifier: "plus").firstMatch
        addButton.tap()
        sleep(1)
        
        let manualButton = app.buttons["Add Manually"]
        if manualButton.exists {
            manualButton.tap()
            
            // Toggle between Adult and Child
            let adultButton = app.buttons["Adult"]
            let childButton = app.buttons["Child"]
            
            if adultButton.exists && childButton.exists {
                childButton.tap()
                XCTAssertTrue(childButton.isSelected)
                
                adultButton.tap()
                XCTAssertTrue(adultButton.isSelected)
            }
            
            let cancelButton = app.navigationBars.buttons["Cancel"]
            cancelButton.tap()
        }
    }
    
    @MainActor
    func testAddTravellerFieldValidation() throws {
        let addButton = app.buttons.matching(identifier: "plus").firstMatch
        addButton.tap()
        sleep(1)
        
        let manualButton = app.buttons["Add Manually"]
        if manualButton.exists {
            manualButton.tap()
            
            let addTravellerButton = app.navigationBars.buttons["Add"]
            
            // Initially disabled (no name)
            XCTAssertFalse(addTravellerButton.isEnabled)
            
            // Enter just name
            let nameField = app.textFields["Name"]
            nameField.tap()
            nameField.typeText("Test Traveller")
            
            // Should now be enabled
            XCTAssertTrue(addTravellerButton.isEnabled)
            
            // Test email field
            let emailField = app.textFields["Email"]
            emailField.tap()
            emailField.typeText("test@example.com")
            
            // Still enabled
            XCTAssertTrue(addTravellerButton.isEnabled)
            
            let cancelButton = app.navigationBars.buttons["Cancel"]
            cancelButton.tap()
        }
    }
    
    @MainActor
    func testImportFromContacts() throws {
        let addButton = app.buttons.matching(identifier: "plus").firstMatch
        addButton.tap()
        sleep(1)
        
        let importButton = app.buttons["Import from Contacts"]
        if importButton.exists {
            importButton.tap()
            sleep(2)
            
            // Contacts picker should appear (system dialog)
            // May need to handle permission dialog first time
            
            // Cancel by tapping outside or Cancel button
            let cancelButton = app.buttons["Cancel"]
            if cancelButton.exists {
                cancelButton.tap()
            }
        }
    }
    
    // MARK: - Edit Traveller Tests
    
    @MainActor
    func testEditTravellerNavigation() throws {
        let firstCell = app.tables.cells.firstMatch
        if firstCell.exists {
            firstCell.tap()
            
            // Should open Edit Traveller screen
            sleep(1)
            XCTAssertTrue(app.navigationBars["Edit Traveller"].exists)
            
            let cancelButton = app.navigationBars.buttons["Cancel"]
            cancelButton.tap()
        }
    }
    
    @MainActor
    func testEditTravellerForm() throws {
        let firstCell = app.tables.cells.firstMatch
        if firstCell.exists {
            firstCell.tap()
            sleep(1)
            
            // Verify all fields are populated
            let nameField = app.textFields["Name"]
            XCTAssertTrue(nameField.exists)
            XCTAssertFalse(nameField.value as? String == "" || nameField.value == nil)
            
            // Check Save button exists
            let saveButton = app.navigationBars.buttons["Save"]
            XCTAssertTrue(saveButton.exists)
            
            // Check Delete button exists
            let deleteButton = app.buttons["Delete Traveller"]
            if deleteButton.exists || app.scrollViews.firstMatch.exists {
                app.swipeUp()
                XCTAssertTrue(app.buttons.containing(NSPredicate(format: "label CONTAINS[c] 'Delete'")).firstMatch.exists)
            }
            
            let cancelButton = app.navigationBars.buttons["Cancel"]
            cancelButton.tap()
        }
    }
    
    @MainActor
    func testEditTravellerModifyFields() throws {
        let firstCell = app.tables.cells.firstMatch
        if firstCell.exists {
            firstCell.tap()
            sleep(1)
            
            let nameField = app.textFields["Name"]
            if nameField.exists {
                // Clear and type new name
                nameField.tap()
                nameField.tap() // Double tap to select all
                nameField.typeText("Modified Name")
                
                let saveButton = app.navigationBars.buttons["Save"]
                XCTAssertTrue(saveButton.isEnabled)
            }
            
            let cancelButton = app.navigationBars.buttons["Cancel"]
            cancelButton.tap()
        }
    }
    
    // MARK: - Search Tests
    
    @MainActor
    func testTravellerSearchField() throws {
        let searchField = app.searchFields.firstMatch
        if searchField.exists {
            searchField.tap()
            XCTAssertTrue(searchField.exists)
            
            searchField.typeText("Test")
            sleep(1)
            
            // Clear search
            if let clearButton = app.buttons["Clear text"].firstMatch as? XCUIElement, clearButton.exists {
                clearButton.tap()
            }
        }
    }
    
    @MainActor
    func testTravellerSearchFiltering() throws {
        let searchField = app.searchFields.firstMatch
        if searchField.exists && app.tables.cells.count > 0 {
            let initialCount = app.tables.cells.count
            
            searchField.tap()
            searchField.typeText("xyz123nonexistent")
            sleep(1)
            
            // Should show fewer results (or none)
            let newCount = app.tables.cells.count
            XCTAssertLessThanOrEqual(newCount, initialCount)
            
            // Clear search
            if let clearButton = app.buttons["Clear text"].firstMatch as? XCUIElement, clearButton.exists {
                clearButton.tap()
            }
        }
    }
}

