import XCTest

final class TravelMarkUITests: XCTestCase {

    let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }

    // 1. UI Test: Full "Happy Path" for adding a new trip
    func testAddNewTripFlow() throws {
        XCTAssertTrue(app.navigationBars["TravelMark"].exists)
        
        let addButton = app.buttons["Add a New Trip"]
        XCTAssertTrue(addButton.exists)
        addButton.tap()
        
        let titleField = app.textFields["Title"]
        titleField.tap()
        titleField.typeText("Vacation 2026")
        
        let locationField = app.textFields["Location"]
        locationField.tap()
        locationField.typeText("Hawaii")
        
        let saveButton = app.buttons["Save Trip"]
        XCTAssertTrue(saveButton.exists)
        saveButton.tap()
        
        // Verify it appears in the list
        XCTAssertTrue(app.staticTexts["Vacation 2026"].exists)
    }
    
    // 2. UI Test: Navigation and View Consistency (Insights)
    func testNavigationToInsights() throws {
        let insightsButton = app.buttons["View Travel Insights"]
        XCTAssertTrue(insightsButton.exists)
        insightsButton.tap()
        
        XCTAssertTrue(app.staticTexts["Travel Insights"].exists)
        
        // Navigate back
        app.navigationBars["Insights"].buttons["TravelMark"].tap()
        XCTAssertTrue(app.navigationBars["TravelMark"].exists)
    }
    
    // 3. UI Test: Context Menu Interaction (Favoriting/Unfavoriting)
    // Note: This requires at least one trip in the list
    func testToggleFavoriteViaContextMenu() throws {
        let tripCard = app.staticTexts.containing(NSPredicate(format: "label CONTAINS 'Trip'")).firstMatch
        if tripCard.exists {
            tripCard.press(forDuration: 1.5)
            
            let favoriteButton = app.buttons.element(boundBy: 0) // Usually the first item in context menu
            XCTAssertTrue(favoriteButton.exists)
            favoriteButton.tap()
        }
    }
    
    // 4. UI Test: Deletion via Context Menu
    func testDeleteTripViaContextMenu() throws {
        // Create a trip first to ensure existence
        testAddNewTripFlow()
        
        let tripCard = app.staticTexts["Vacation 2026"]
        XCTAssertTrue(tripCard.exists)
        tripCard.press(forDuration: 1.5)
        
        let deleteButton = app.buttons["Delete Trip"]
        XCTAssertTrue(deleteButton.exists)
        deleteButton.tap()
        
        // Verify it's gone
        XCTAssertFalse(app.staticTexts["Vacation 2026"].exists)
    }
    
    // 5. UI Test: Settings Navigation and Interaction
    func testSettingsFlow() throws {
        let settingsButton = app.buttons["gearshape.fill"] // SF Symbol button
        XCTAssertTrue(settingsButton.exists)
        settingsButton.tap()
        
        XCTAssertTrue(app.navigationBars["Settings"].exists)
        
        let nameField = app.textFields.firstMatch
        if nameField.exists {
            nameField.tap()
            nameField.clearText()
            nameField.typeText("Global Traveler")
        }
        
        app.buttons["Done"].tap() // Or swipe down if it's a sheet
        XCTAssertTrue(app.navigationBars["TravelMark"].exists)
    }
}

// Helper to clear text in UI Tests
extension XCUIElement {
    func clearText() {
        guard let stringValue = self.value as? String else { return }
        var deleteString = ""
        for _ in stringValue {
            deleteString += XCUIIdentifierKeys.delete.rawValue
        }
        self.typeText(deleteString)
    }
}
