import SwiftUI
import CoreData
import Combine

class TripViewModel: NSObject, ObservableObject, NSFetchedResultsControllerDelegate {
    @Published var trips: [TripEntity] = []
    
    private let controller: NSFetchedResultsController<TripEntity>
    
    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        let request = TripEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \TripEntity.startDate, ascending: true)]
        
        self.controller = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        super.init()
        self.controller.delegate = self
        
        do {
            try controller.performFetch()
            trips = controller.fetchedObjects ?? []
        } catch {
            print("Error fetching trips: \(error)")
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        if let newTrips = controller.fetchedObjects as? [TripEntity] {
            trips = newTrips
        }
    }
    
    func deleteTrip(_ trip: TripEntity) {
        let context = controller.managedObjectContext
        context.delete(trip)
        saveContext(context: context)
    }
    
    func toggleFavorite(_ trip: TripEntity) {
        trip.isFavorite.toggle()
        saveContext(context: controller.managedObjectContext)
    }
    
    func sortedTrips(by preference: String) -> [TripEntity] {
        if preference == "Date" {
            return trips.sorted { ($0.startDate ?? Date()) < ($1.startDate ?? Date()) }
        } else {
            return trips.sorted { ($0.location ?? "") < ($1.location ?? "") }
        }
    }
    
    private func saveContext(context: NSManagedObjectContext) {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Error saving context: \(error)")
            }
        }
    }
}
