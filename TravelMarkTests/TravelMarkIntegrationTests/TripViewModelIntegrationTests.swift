import XCTest
import CoreData
@testable import TravelMark_shamshad

final class TripViewModelIntegrationTests: XCTestCase {
    
    var tripViewModel: TripViewModel!
    var addTripViewModel: AddTripViewModel!
    var context: NSManagedObjectContext!
    
    override func setUp() {
        super.setUp()
        // 1. Integration: Verify PersistenceController.preview correctly provides an in-memory context
        context = PersistenceController.preview.container.viewContext
        tripViewModel = TripViewModel(context: context)
        addTripViewModel = AddTripViewModel(context: context)
        
        // Clear existing data for isolation
        let request = TripEntity.fetchRequest()
        let result = try? context.fetch(request)
        result?.forEach(context.delete)
        try? context.save()
    }
    
    override func tearDown() {
        tripViewModel = nil
        addTripViewModel = nil
        context = nil
        super.tearDown()
    }
    
    // 2. Integration: AddTripViewModel -> CoreData -> TripViewModel (Reactive UI Feed)
    func testAddTripViewModelFlowUpdatesTripViewModel() {
        addTripViewModel.title = "Integration Test"
        addTripViewModel.location = "New York"
        addTripViewModel.startDate = Date()
        addTripViewModel.endDate = Date().addingTimeInterval(3600)
        
        XCTAssertTrue(addTripViewModel.saveTrip())
        
        // TripViewModel should automatically pick up the new trip via NSFetchedResultsController
        XCTAssertEqual(tripViewModel.trips.count, 1)
        XCTAssertEqual(tripViewModel.trips.first?.title, "Integration Test")
    }
    
    // 3. Integration: TripViewModel -> CoreData -> Delete Operation
    func testDeleteTripDirectlyFromViewModel() {
        let trip = TripEntity(context: context)
        trip.title = "Delete Me"
        try? context.save()
        
        XCTAssertEqual(tripViewModel.trips.count, 1)
        
        tripViewModel.deleteTrip(trip)
        XCTAssertEqual(tripViewModel.trips.count, 0)
    }
    
    // 4. Integration: TripViewModel -> CoreData -> State Persistence (Favorite)
    func testFavoritingPersistence() {
        let trip = TripEntity(context: context)
        trip.title = "Fav Trip"
        trip.isFavorite = false
        try? context.save()
        
        tripViewModel.toggleFavorite(trip)
        XCTAssertTrue(trip.isFavorite)
        
        // Verify it was actually saved to context
        let fetchRequest = TripEntity.fetchRequest()
        let savedTrips = try? context.fetch(fetchRequest)
        XCTAssertEqual(savedTrips?.first?.isFavorite, true)
    }
    
    // 5. Integration: TripViewModel Sorting Logic with Real Entities
    func testMultiTripSortingConsistency() {
        let trip1 = TripEntity(context: context)
        trip1.title = "B Trip"
        trip1.location = "Zürich"
        trip1.startDate = Date().addingTimeInterval(1000)
        
        let trip2 = TripEntity(context: context)
        trip2.title = "A Trip"
        trip2.location = "Amsterdam"
        trip2.startDate = Date()
        
        try? context.save()
        
        // Sort by Location
        let locationSorted = tripViewModel.sortedTrips(by: "Location")
        XCTAssertEqual(locationSorted.first?.location, "Amsterdam")
        
        // Sort by Date
        let dateSorted = tripViewModel.sortedTrips(by: "Date")
        XCTAssertEqual(dateSorted.first?.title, "A Trip")
    }
    
    // 6. Integration: InsightsViewModel -> Data Dependency on TripViewModel's state
    func testInsightsViewModelIntegrationWithCoreData() {
        let trip = TripEntity(context: context)
        trip.title = "Insights Trip"
        trip.location = "Tokyo"
        trip.startDate = Date()
        try? context.save()
        
        // InsightsViewModel usually gets data from the fetched trips
        let insightsVM = InsightsViewModel(trips: tripViewModel.trips)
        XCTAssertEqual(insightsVM.trips.count, 1)
        XCTAssertEqual(insightsVM.tripsByLocation.first?.location, "Tokyo")
    }
    
    // 7. Integration: Partial Data Update (Notes Edit)
    func testTripEntityAttributeUpdate() {
        let trip = TripEntity(context: context)
        trip.notes = "Initial Notes"
        try? context.save()
        
        trip.notes = "Updated Notes"
        try? context.save()
        
        XCTAssertEqual(tripViewModel.trips.first?.notes, "Updated Notes")
    }
    
    // 8. Integration: Multi-object Batch Handling (Simulated Delete All)
    func testBatchDeletionReactivity() {
        for i in 1...5 {
            let t = TripEntity(context: context)
            t.title = "Trip \(i)"
        }
        try? context.save()
        XCTAssertEqual(tripViewModel.trips.count, 5)
        
        tripViewModel.trips.forEach(context.delete)
        try? context.save()
        
        XCTAssertEqual(tripViewModel.trips.count, 0)
    }
    
    // 9. Integration: Date Range Logic across Year Boundary Persistence
    func testYearBoundaryDateIntegration() {
        let trip = TripEntity(context: context)
        let calendar = Calendar.current
        trip.startDate = calendar.date(from: DateComponents(year: 2024, month: 12, day: 31))
        trip.endDate = calendar.date(from: DateComponents(year: 2025, month: 1, day: 2))
        try? context.save()
        
        let insightsVM = InsightsViewModel(trips: tripViewModel.trips)
        XCTAssertEqual(insightsVM.durationInDays(trip), 2)
    }
    
    // 10. Integration: Verify AppStorage influence on ViewModel output (Sort Preference)
    func testAppStorageSortLogicIntegration() {
        let trip1 = TripEntity(context: context)
        trip1.location = "C"
        let trip2 = TripEntity(context: context)
        trip2.location = "A"
        try? context.save()
        
        // HomeView usually passes sortPreference to VM
        let result = tripViewModel.sortedTrips(by: "Location")
        XCTAssertEqual(result.first?.location, "A")
    }
}
