import XCTest
@testable import TravelMark_shamshad

final class AddTripViewModelTests: XCTestCase {
    
    var viewModel: AddTripViewModel!
    
    override func setUp() {
        super.setUp()
        // Use preview/in-memory context for tests
        let context = PersistenceController.preview.container.viewContext
        viewModel = AddTripViewModel(context: context)
    }
    
    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }
    
    func testInitialState() {
        XCTAssertTrue(viewModel.title.isEmpty)
        XCTAssertTrue(viewModel.location.isEmpty)
        XCTAssertTrue(viewModel.isSaveDisabled)
    }
    
    func testValidation() {
        // 1. Test short title
        viewModel.title = "A"
        viewModel.validateTitle()
        XCTAssertTrue(viewModel.titleError)
        XCTAssertTrue(viewModel.isSaveDisabled)
        
        // 2. Test valid title
        viewModel.title = "Paris Trip"
        viewModel.validateTitle()
        XCTAssertFalse(viewModel.titleError)
        
        // 3. Test empty location
        viewModel.location = ""
        viewModel.validateLocation()
        XCTAssertTrue(viewModel.locationError)
        
        // 4. Test short location
        viewModel.location = "L"
        viewModel.validateLocation()
        XCTAssertTrue(viewModel.locationError)
        
        // 5. Test valid location
        viewModel.location = "London"
        viewModel.validateLocation()
        XCTAssertFalse(viewModel.locationError)
        
        // 6. Test invalid dates (End before Start)
        viewModel.startDate = Date().addingTimeInterval(86400) // Tomorrow
        viewModel.endDate = Date() // Today
        viewModel.validateDates()
        XCTAssertTrue(viewModel.dateError)
        XCTAssertTrue(viewModel.isSaveDisabled)
        
        // 7. Test equal dates (Valid)
        viewModel.startDate = Date()
        viewModel.endDate = viewModel.startDate
        viewModel.validateDates()
        XCTAssertFalse(viewModel.dateError)
    }
    
    func testMoodSelection() {
        // 8. Test initial mood
        XCTAssertEqual(viewModel.selectedMood, "✈️")
        
        // 9. Test changing mood
        viewModel.selectedMood = "🏖️"
        XCTAssertEqual(viewModel.selectedMood, "🏖️")
    }
    
    func testNotesConstraint() {
        // 10. Test notes length (Within limit)
        viewModel.notes = String(repeating: "A", count: 119)
        XCTAssertFalse(viewModel.isSaveDisabled)
        
        // 11. Test notes length (Exceeding limit)
        viewModel.notes = String(repeating: "A", count: 121)
        XCTAssertTrue(viewModel.isSaveDisabled)
    }
    
    func testSaveTripSuccess() {
        // 12. Test full valid sequence
        viewModel.title = "Valid Trip"
        viewModel.location = "London"
        viewModel.startDate = Date()
        viewModel.endDate = Date().addingTimeInterval(3600)
        
        XCTAssertFalse(viewModel.isSaveDisabled)
        XCTAssertTrue(viewModel.saveTrip())
    }
}
