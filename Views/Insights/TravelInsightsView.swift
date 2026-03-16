import SwiftUI
import Charts
import CoreData

struct TravelInsightsView: View {
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \TripEntity.startDate, ascending: true)],
        animation: .default)
    private var trips: FetchedResults<TripEntity>

    @StateObject private var viewModel = InsightsViewModel(trips: [])

    var body: some View {
        ZStack {
            DesignSystem.Colors.background.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    Text("Travel Insights")
                        .font(.largeTitle.bold())
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 20)
                    
                    if trips.isEmpty {
                        emptyState
                    } else {
                        // 1. Bar Chart: Trips per Month
                        VStack(alignment: .leading, spacing: 12) {
                            chartHeader(title: "Trips by Month", icon: "calendar")
                            
                            Chart {
                                ForEach(viewModel.tripsByMonth, id: \.month) { data in
                                    BarMark(
                                        x: .value("Month", data.month),
                                        y: .value("Trips", data.count)
                                    )
                                    .foregroundStyle(DesignSystem.Colors.primary.gradient)
                                    .cornerRadius(4)
                                }
                            }
                            .frame(height: 180)
                        }
                        .cardStyle()
                        
                        // 2. Pie Chart: Trips by Location
                        VStack(alignment: .leading, spacing: 12) {
                            chartHeader(title: "Location Distribution", icon: "mappin.and.ellipse")
                            
                            Chart {
                                ForEach(viewModel.tripsByLocation, id: \.location) { data in
                                    SectorMark(
                                        angle: .value("Trips", data.count),
                                        innerRadius: .ratio(0.6),
                                        angularInset: 1.5
                                    )
                                    .cornerRadius(5)
                                    .foregroundStyle(by: .value("Location", data.location))
                                }
                            }
                            .frame(height: 220)
                        }
                        .cardStyle()
                        
                        // 3. Line Chart: Travel Duration Trend
                        VStack(alignment: .leading, spacing: 12) {
                            chartHeader(title: "Duration Trends", icon: "chart.line.uptrend.xyaxis")
                            
                            Chart {
                                ForEach(trips) { trip in
                                    LineMark(
                                        x: .value("Date", trip.startDate ?? Date()),
                                        y: .value("Days", viewModel.durationInDays(trip))
                                    )
                                    .foregroundStyle(DesignSystem.Colors.secondary.gradient)
                                    .interpolationMethod(.catmullRom)
                                    .symbol(.circle)
                                }
                            }
                            .frame(height: 180)
                        }
                        .cardStyle()
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Insights")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.trips = Array(trips)
        }
        .onChange(of: trips.count) {
            viewModel.trips = Array(trips)
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.pie.fill")
                .font(.system(size: 80))
                .foregroundStyle(.tertiary)
            Text("No Data Available")
                .font(.headline)
            Text("Add some trips to see your travel trends.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 80)
    }
    
    private func chartHeader(title: String, icon: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(DesignSystem.Colors.primary)
            Text(title)
                .font(.headline)
        }
    }
}

#Preview {
    TravelInsightsView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
