//
//  TravelMark_shamshadApp.swift
//  TravelMark_shamshad
//
//  Created by Shamshad on 2025-09-24.
//

import SwiftUI
import CoreData

@main
struct TravelMark_shamshadApp: App {
    let persistenceController = PersistenceController.shared
    @AppStorage("appearanceMode") private var appearanceMode: String = "System"

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .preferredColorScheme(colorScheme)
        }
    }
    
    private var colorScheme: ColorScheme? {
        switch appearanceMode {
        case "Light": return .light
        case "Dark": return .dark
        default: return nil
        }
    }
}
