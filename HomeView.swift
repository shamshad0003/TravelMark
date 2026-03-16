import SwiftUI
import CoreData
import Combine

struct HomeView: View {
    
    @Environment(\.managedObjectContext) private var viewContext

    @StateObject private var viewModel = TripViewModel()
    @AppStorage("userName") private var userName: String = "Traveler"
    @AppStorage("sortPreference") private var sortPreference: String = "Date"
    @AppStorage("preferredTripType") private var preferredTripType: String = "Solo"
    
    @State private var showingAddTrip = false
    @State private var showingSettings = false
    @State private var selectedTrip: TripEntity?

    var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 12 { return "Good Morning" }
        if hour < 17 { return "Good Afternoon" }
        return "Good Evening"
    }

    private var sortedTrips: [TripEntity] {
        viewModel.sortedTrips(by: sortPreference)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                DesignSystem.Colors.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        headerSection
                        
                        if viewModel.trips.isEmpty {
                            emptyStateSection
                        } else {
                            tripListSection
                        }
                        
                        insightsButton
                    }
                    .padding()
                }
            }
            .navigationTitle("TravelMark")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .foregroundStyle(DesignSystem.Colors.primary)
                    }
                }
                
                ToolbarItem(placement: .bottomBar) {
                    Button {
                        showingAddTrip = true
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Add a New Trip")
                        }
                        .font(.headline)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 12)
                        .background(DesignSystem.Colors.primary)
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                        .shadow(radius: 5)
                    }
                }
            }
            .sheet(isPresented: $showingAddTrip) {
                AddTripView()
                    .environment(\.managedObjectContext, viewContext)
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
        }
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("\(greeting),")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text(userName)
                .font(.largeTitle.bold())
        }
        .padding(.top, 10)
    }
    
    private var emptyStateSection: some View {
        VStack(spacing: 20) {
            Image(systemName: "airplane.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(DesignSystem.Colors.primary.opacity(0.3))
            
            Text("No Trips Found")
                .font(.title3.bold())
            
            Text("Plan your next adventure by tapping the button below.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }

    private var insightsButton: some View {
        NavigationLink(destination: TravelInsightsView()) {
            HStack {
                Image(systemName: "chart.bar.fill")
                Text("View Travel Insights")
            }
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding()
            .background(DesignSystem.Colors.primary.opacity(0.1))
            .foregroundStyle(DesignSystem.Colors.primary)
            .clipShape(RoundedRectangle(cornerRadius: 15))
        }
    }
    
    private var tripListSection: some View {
        LazyVStack(spacing: 16) {
            ForEach(sortedTrips) { trip in
                NavigationLink(destination: TripDetailView(trip: trip)) {
                    HStack(spacing: 15) {
                        Text(trip.mood ?? "✈️")
                            .font(.system(size: 40))
                            .padding(8)
                            .background(DesignSystem.Colors.primary.opacity(0.1))
                            .clipShape(Circle())

                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text(trip.title ?? "Trip")
                                    .font(.headline)
                                    .foregroundStyle(.primary)
                                
                                if trip.isFavorite {
                                    Image(systemName: "heart.fill")
                                        .foregroundStyle(.red)
                                        .font(.caption)
                                }
                             }
                            
                            HStack {
                                Image(systemName: "mappin.and.ellipse")
                                Text(trip.location ?? "Unknown")
                            }
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            
                            HStack {
                                Image(systemName: "calendar")
                                Text(trip.startDate ?? Date(), style: .date)
                            }
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.caption.bold())
                            .foregroundStyle(.tertiary)
                    }
                    .cardStyle()
                }
                .contextMenu {
                    Button {
                        viewModel.toggleFavorite(trip)
                    } label: {
                        Label(trip.isFavorite ? "Unfavorite" : "Favorite", systemImage: trip.isFavorite ? "heart.slash" : "heart")
                    }

                    Button(role: .destructive) {
                        viewModel.deleteTrip(trip)
                    } label: {
                        Label("Delete Trip", systemImage: "trash")
                    }
                }
            }
        }
    }
}

#Preview {
    HomeView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
