import XCTest
import CoreData
@testable import TravelMark_shamshad

final class InsightsViewModelTests: XCTestCase {
    
    var viewModel: InsightsViewModel!
    var context: NSManagedObjectContext!
    
    override func setUp() {
        super.setUp()
        context = PersistenceController.preview.container.viewContext
        
        // Create mock data
        let trip1 = TripEntity(context: context)
        trip1.title = "Summer Beach"
        trip1.location = "Bali"
        trip1.startDate = Calendar.current.date(from: DateComponents(year: 2024, month: 6, day: 10))
        trip1.endDate = Calendar.current.date(from: DateComponents(year: 2024, month: 6, day: 20))
        
        let trip2 = TripEntity(context: context)
        trip2.title = "Mountain Hike"
        trip2.location = "Swiss Alps"
        trip2.startDate = Calendar.current.date(from: DateComponents(year: 2024, month: 7, day: 5))
        trip2.endDate = Calendar.current.date(from: DateComponents(year: 2024, month: 7, day: 10))
        
        viewModel = InsightsViewModel(trips: [trip1, trip2])
    }
    
    override func tearDown() {
        viewModel = nil
        context = nil
        super.tearDown()
    }
    
    func testTripsByMonthGrouping() {
        // 13. Test count of groups
        let months = viewModel.tripsByMonth
        XCTAssertEqual(months.count, 2)
        
        // 14. Test specific group content
        XCTAssertTrue(months.contains { $0.month == "Jun" && $0.count == 1 })
        XCTAssertTrue(months.contains { $0.month == "Jul" && $0.count == 1 })
        
        // 15. Test chronological order
        XCTAssertEqual(months[0].month, "Jun")
        XCTAssertEqual(months[1].month, "Jul")
    }
    
    func testTripsByLocationGrouping() {
        // 16. Test location count
        let locations = viewModel.tripsByLocation
        XCTAssertEqual(locations.count, 2)
        
        // 17. Test specific location presence
        XCTAssertTrue(locations.contains { $0.location == "Bali" })
    }
    
    func testDurationInDays() {
        // 18. Test standard positive duration
        let trip = viewModel.trips.first!
        let duration = viewModel.durationInDays(trip)
        XCTAssertEqual(duration, 10) // June 10 to June 20
        
        // 19. Test same day duration
        let sameDayTrip = TripEntity(context: context)
        sameDayTrip.startDate = Date()
        sameDayTrip.endDate = sameDayTrip.startDate
        XCTAssertEqual(viewModel.durationInDays(sameDayTrip), 0)
        
        // 20. Test duration across year boundary
        let yearTrip = TripEntity(context: context)
        yearTrip.startDate = Calendar.current.date(from: DateComponents(year: 2024, month: 12, day: 31))
        yearTrip.endDate = Calendar.current.date(from: DateComponents(year: 2025, month: 1, day: 2))
        XCTAssertEqual(viewModel.durationInDays(yearTrip), 2)
    }
}
