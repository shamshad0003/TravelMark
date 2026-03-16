import SwiftUI
import CoreData
import Combine

class AddTripViewModel: ObservableObject {
    @Published var title: String = ""
    @Published var location: String = ""
    @Published var startDate: Date = Date()
    @Published var endDate: Date = Date()
    @Published var notes: String = ""
    @Published var selectedMood: String = "✈️"
    
    @Published var titleError: Bool = false
    @Published var locationError: Bool = false
    @Published var dateError: Bool = false
    
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.context = context
    }
    
    var isSaveDisabled: Bool {
        title.isEmpty || title.count < 2 || 
        location.isEmpty || location.count < 2 || 
        startDate > endDate || 
        notes.count > 120
    }
    
    func validateTitle() {
        titleError = title.isEmpty || title.count < 2
    }
    
    func validateLocation() {
        locationError = location.isEmpty || location.count < 2
    }
    
    func validateDates() {
        dateError = startDate > endDate
    }
    
    func saveTrip() -> Bool {
        guard !isSaveDisabled else { return false }
        
        let newTrip = TripEntity(context: context)
        newTrip.title = title
        newTrip.location = location
        newTrip.startDate = startDate
        newTrip.endDate = endDate
        newTrip.notes = notes
        newTrip.mood = selectedMood
        newTrip.isFavorite = false
        
        do {
            try context.save()
            return true
        } catch {
            print("Error saving trip: \(error)")
            return false
        }
    }
}
