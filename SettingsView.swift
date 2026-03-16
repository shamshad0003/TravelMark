import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    
    // User Profile
    @AppStorage("userName") private var userName: String = "Traveler"
    @AppStorage("preferredTripType") private var preferredTripType: String = "Solo"
    
    // Appearance
    @AppStorage("appearanceMode") private var appearanceMode: String = "System"
    
    // Preferences
    @AppStorage("sortPreference") private var sortPreference: String = "Date"
    
    let tripTypes = ["Solo", "Family", "Friends", "Business"]
    let appearances = ["System", "Light", "Dark"]
    let sortOptions = ["Date", "Location"]
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("User Profile")) {
                    TextField("Name", text: $userName)
                    Picker("Preferred Trip Type", selection: $preferredTripType) {
                        ForEach(tripTypes, id: \.self) { type in
                            Text(type).tag(type)
                        }
                    }
                }
                
                Section(header: Text("Appearance")) {
                    Picker("Mode", selection: $appearanceMode) {
                        ForEach(appearances, id: \.self) { mode in
                            Text(mode).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section(header: Text("Preferences")) {
                    Picker("Sort Trips By", selection: $sortPreference) {
                        ForEach(sortOptions, id: \.self) { option in
                            Text(option).tag(option)
                        }
                    }
                }
                
                Section(header: Text("App Information")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }
                    HStack {
                        Text("Author")
                        Spacer()
                        Text("Shamshad")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    SettingsView()
}
