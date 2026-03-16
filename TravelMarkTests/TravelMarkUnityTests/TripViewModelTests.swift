import XCTest
import CoreData
@testable import TravelMark_shamshad

final class TripViewModelTests: XCTestCase {
    
    var viewModel: TripViewModel!
    var context: NSManagedObjectContext!
    
    override func setUp() {
        super.setUp()
        context = PersistenceController.preview.container.viewContext
        viewModel = TripViewModel(context: context)
        
        // Cleanup and Setup Mock Data
        let request = TripEntity.fetchRequest()
        let results = try? context.fetch(request)
        results?.forEach(context.delete)
        
        let t1 = TripEntity(context: context)
        t1.title = "Trip A"
        t1.location = "Zurich"
        t1.startDate = Date().addingTimeInterval(1000)
        
        let t2 = TripEntity(context: context)
        t2.title = "Trip B"
        t2.location = "Amsterdam"
        t2.startDate = Date()
        
        try? context.save()
    }
    
    override func tearDown() {
        viewModel = nil
        context = nil
        super.tearDown()
    }
    
    func testSortingLogic() {
        // 21. Test sorting by Date (Default Ascending)
        let dateSorted = viewModel.sortedTrips(by: "Date")
        XCTAssertEqual(dateSorted.first?.location, "Amsterdam")
        
        // 22. Test sorting by Location (Alphabetical)
        let locationSorted = viewModel.sortedTrips(by: "Location")
        XCTAssertEqual(locationSorted.first?.location, "Amsterdam")
        XCTAssertEqual(locationSorted.last?.location, "Zurich")
    }
    
    func testFavoriteToggle() {
        let trip = viewModel.trips.first!
        let initialState = trip.isFavorite
        
        // 23. Test toggling favorited
        viewModel.toggleFavorite(trip)
        XCTAssertNotEqual(trip.isFavorite, initialState)
        
        // 24. Test toggling back
        viewModel.toggleFavorite(trip)
        XCTAssertEqual(trip.isFavorite, initialState)
    }
    
    func testDeleteLogic() {
        let tripCount = viewModel.trips.count
        let tripToDelete = viewModel.trips.first!
        
        // 25. Test deleting a trip
        viewModel.deleteTrip(tripToDelete)
        XCTAssertEqual(viewModel.trips.count, tripCount - 1)
    }
}
