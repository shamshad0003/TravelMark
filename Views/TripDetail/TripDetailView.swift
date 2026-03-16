//
//  TripDetailView.swift
//  TravelMark_shamshad
//
//  Created by Shamshad on 2025-09-24.
//

import SwiftUI
import CoreData

struct TripDetailView: View {
    @ObservedObject var trip: TripEntity
    
    var tripDuration: Int {
        let calendar = Calendar.current
        let startOfStart = calendar.startOfDay(for: trip.startDate ?? Date())
        let startOfEnd = calendar.startOfDay(for: trip.endDate ?? Date())
        let components = calendar.dateComponents(
            [.day],
            from: startOfStart,
            to: startOfEnd
        )
        return components.day ?? 0
    }
    
    var body: some View {
        ZStack {
            DesignSystem.Colors.background.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Header Section
                    VStack(spacing: 8) {
                        ZStack(alignment: .bottomTrailing) {
                            Text(trip.mood ?? "✈️")
                                .font(.system(size: 80))
                                .padding(20)
                                .background(DesignSystem.Colors.primary.opacity(0.1))
                                .clipShape(Circle())
                            
                            if trip.isFavorite {
                                Image(systemName: "heart.fill")
                                    .font(.title)
                                    .foregroundStyle(.red)
                                    .background(Circle().fill(DesignSystem.Colors.cardBackground))
                                    .offset(x: -5, y: -5)
                            }
                        }
                        .padding(.bottom, 10)
                        
                        Text(trip.title ?? "Trip Details")
                            .font(.largeTitle.bold())
                            .multilineTextAlignment(.center)
                        
                        HStack {
                            Image(systemName: "mappin.and.ellipse")
                            Text(trip.location ?? "Unknown Location")
                        }
                        .font(.title3)
                        .foregroundStyle(.secondary)
                    }
                    .padding(.top, 20)
                    
                    // Stats/Dates Card
                    VStack(spacing: 16) {
                        detailRow(icon: "calendar.badge.clock", title: "Starts", value: trip.startDate?.formatted(date: .long, time: .omitted) ?? "N/A")
                        
                        Divider()
                        
                        detailRow(icon: "calendar.badge.exclamationmark", title: "Ends", value: trip.endDate?.formatted(date: .long, time: .omitted) ?? "N/A")
                        
                        Divider()
                        
                        HStack {
                            Label("Duration", systemImage: "timer")
                                .font(.headline)
                            Spacer()
                            Text("\(tripDuration) Days")
                                .font(.headline)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(DesignSystem.Colors.primary.opacity(0.1))
                                .foregroundStyle(DesignSystem.Colors.primary)
                                .clipShape(Capsule())
                        }
                    }
                    .cardStyle()
                    
                    // Notes Section
                    if let notes = trip.notes, !notes.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Label("Notes", systemImage: "note.text")
                                .font(.headline)
                            
                            Text(notes)
                                .font(.body)
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .cardStyle()
                    }
                    
                    Spacer()
                }
                .padding()
            }
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func detailRow(icon: String, title: String, value: String) -> some View {
        HStack {
            Label(title, systemImage: icon)
                .font(.headline)
            Spacer()
            Text(value)
                .foregroundStyle(.secondary)
        }
    }
}
    
#Preview {
    let trip: TripEntity = {
        let context = PersistenceController.preview.container.viewContext
        let trip = TripEntity(context: context)
        trip.title = "Sample Trip"
        trip.location = "Sample Location"
        trip.startDate = Date()
        trip.endDate = Date().addingTimeInterval(86400)
        trip.notes = "Sample notes"
        return trip
    }()
    
    TripDetailView(trip: trip)
}

