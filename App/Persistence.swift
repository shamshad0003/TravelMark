import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        for i in 0..<5 {
            let newTrip = TripEntity(context: viewContext)
            newTrip.title = "Sample Trip \(i)"
            newTrip.location = "Location \(i)"
            newTrip.startDate = Date().addingTimeInterval(Double(i) * 86400)
            newTrip.endDate = Date().addingTimeInterval(Double(i + 1) * 86400)
            newTrip.notes = "Notes for trip \(i)"
        }
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            print("Preview save error: \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        let model: NSManagedObjectModel
        
        if let modelURL = Bundle.allBundles.compactMap({ $0.url(forResource: "TravelMark", withExtension: "momd") }).first,
           let mom = NSManagedObjectModel(contentsOf: modelURL) {
            model = mom
        } else {
            // Programmatic fallback to ensure 'TripEntity' ALWAYS exists
            model = Self.createProgrammaticModel()
        }
        
        container = NSPersistentContainer(name: "TravelMark", managedObjectModel: model)
        
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                print("Core Data failed to load store: \(error), \(error.userInfo)")
            }
        })
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }

    private static func createProgrammaticModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()
        
        let entity = NSEntityDescription()
        entity.name = "TripEntity"
        entity.managedObjectClassName = "TripEntity"
        
        let titleAttribute = NSAttributeDescription()
        titleAttribute.name = "title"
        titleAttribute.attributeType = .stringAttributeType
        titleAttribute.isOptional = false
        
        let locationAttribute = NSAttributeDescription()
        locationAttribute.name = "location"
        locationAttribute.attributeType = .stringAttributeType
        locationAttribute.isOptional = false
        
        let startDateAttribute = NSAttributeDescription()
        startDateAttribute.name = "startDate"
        startDateAttribute.attributeType = .dateAttributeType
        startDateAttribute.isOptional = false
        
        let endDateAttribute = NSAttributeDescription()
        endDateAttribute.name = "endDate"
        endDateAttribute.attributeType = .dateAttributeType
        endDateAttribute.isOptional = false
        
        let notesAttribute = NSAttributeDescription()
        notesAttribute.name = "notes"
        notesAttribute.attributeType = .stringAttributeType
        notesAttribute.isOptional = true

        let moodAttribute = NSAttributeDescription()
        moodAttribute.name = "mood"
        moodAttribute.attributeType = .stringAttributeType
        moodAttribute.isOptional = true

        let isFavoriteAttribute = NSAttributeDescription()
        isFavoriteAttribute.name = "isFavorite"
        isFavoriteAttribute.attributeType = .booleanAttributeType
        isFavoriteAttribute.isOptional = false
        isFavoriteAttribute.defaultValue = false
        
        entity.properties = [titleAttribute, locationAttribute, startDateAttribute, endDateAttribute, notesAttribute, moodAttribute, isFavoriteAttribute]
        model.entities = [entity]
        
        return model
    }
}
