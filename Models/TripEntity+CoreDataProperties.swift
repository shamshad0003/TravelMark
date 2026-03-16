import Foundation
import CoreData

extension TripEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TripEntity> {
        return NSFetchRequest<TripEntity>(entityName: "TripEntity")
    }

    @NSManaged public var title: String?
    @NSManaged public var location: String?
    @NSManaged public var startDate: Date?
    @NSManaged public var endDate: Date?
    @NSManaged public var notes: String?
    @NSManaged public var mood: String?
    @NSManaged public var isFavorite: Bool

}

extension TripEntity : Identifiable {

}
