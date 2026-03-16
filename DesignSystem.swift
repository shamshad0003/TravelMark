import SwiftUI

struct DesignSystem {
    struct Colors {
        static let primary = Color.blue
        static let secondary = Color.orange
        static let background = Color(uiColor: .systemGroupedBackground) // Adaptive background
        static let cardBackground = Color(uiColor: .secondarySystemGroupedBackground)
        
        static let tripBusiness = Color.purple
        static let tripSolo = Color.blue
        static let tripFamily = Color.green
        static let tripFriends = Color.orange
    }
    
    struct Radius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 16
        static let large: CGFloat = 24
    }
    
    struct Padding {
        static let small: CGFloat = 8
        static let medium: CGFloat = 16
        static let large: CGFloat = 24
    }
}

// Helper to get color for trip type
extension DesignSystem {
    static func colorForTripType(_ type: String) -> Color {
        switch type {
        case "Business": return Colors.tripBusiness
        case "Solo": return Colors.tripSolo
        case "Family": return Colors.tripFamily
        case "Friends": return Colors.tripFriends
        default: return Colors.primary
        }
    }
}

extension View {
    func cardStyle() -> some View {
        self.padding()
            .background(DesignSystem.Colors.cardBackground)
            .cornerRadius(DesignSystem.Radius.medium)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}
