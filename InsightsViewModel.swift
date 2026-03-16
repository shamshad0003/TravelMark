import SwiftUI
import CoreData
import Combine

class InsightsViewModel: ObservableObject {
    @Published var trips: [TripEntity] = []
    
    init(trips: [TripEntity]) {
        self.trips = trips
    }
    
    var tripsByMonth: [(month: String, count: Int)] {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        
        let grouped = Dictionary(grouping: trips) { trip in
            formatter.string(from: trip.startDate ?? Date())
        }
        
        return grouped.map { (month: $0.key, count: $0.value.count) }
            .sorted { (m1, m2) -> Bool in
                let d1 = formatter.date(from: m1.month) ?? Date()
                let d2 = formatter.date(from: m2.month) ?? Date()
                return d1 < d2
            }
    }
    
    var tripsByLocation: [(location: String, count: Int)] {
        let grouped = Dictionary(grouping: trips) { trip in
            trip.location ?? "Unknown"
        }
        return grouped.map { (location: $0.key, count: $0.value.count) }
            .sorted { $0.count > $1.count }
    }
    
    func durationInDays(_ trip: TripEntity) -> Int {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: trip.startDate ?? Date())
        let end = calendar.startOfDay(for: trip.endDate ?? Date())
        return calendar.dateComponents([.day], from: start, to: end).day ?? 0
    }
}
