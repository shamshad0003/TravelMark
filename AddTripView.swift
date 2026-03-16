import SwiftUI
import CoreData
import Combine

struct AddTripView: View {

    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) var dismiss

    @StateObject private var viewModel: AddTripViewModel

    init() {
        _viewModel = StateObject(wrappedValue: AddTripViewModel())
    }

    init(context: NSManagedObjectContext) {
        _viewModel = StateObject(wrappedValue: AddTripViewModel(context: context))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    titleSection
                    locationSection
                    dateSection
                    moodSection
                    notesSection
                    
                    Spacer()
                    
                    actionButtons
                }
                .padding()
            }
            .navigationTitle("New Trip")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    // MARK: - Sub-sections
    
    private var titleSection: some View {
        VStack(alignment: .leading) {
            TextField("Title", text: $viewModel.title)
                .padding()
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.secondary.opacity(0.5)))
                .onSubmit {
                    viewModel.validateTitle()
                }
            
            if viewModel.titleError {
                Text("Title should at least 2 characters.")
                    .foregroundColor(.red)
                    .font(.caption)
            }
        }
    }
    
    private var locationSection: some View {
        VStack(alignment: .leading) {
            TextField("Location", text: $viewModel.location)
                .padding()
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.secondary.opacity(0.5)))
                .onSubmit {
                    viewModel.validateLocation()
                }
            
            if viewModel.locationError {
                Text("Location should at least 2 characters.")
                    .foregroundColor(.red)
                    .font(.caption)
            }
        }
    }
    
    private var dateSection: some View {
        VStack(alignment: .leading) {
            VStack {
                DatePicker("Start Date", selection: $viewModel.startDate, displayedComponents: [.date])
                DatePicker("End Date", selection: $viewModel.endDate, displayedComponents: [.date])
            }
            .padding()
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.secondary.opacity(0.5)))
            .onChange(of: viewModel.startDate) { viewModel.validateDates() }
            .onChange(of: viewModel.endDate) { viewModel.validateDates() }

            if viewModel.dateError {
                Text("End Date should be after Start Date.")
                    .foregroundColor(.red)
                    .font(.caption)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
    
    private var moodSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Trip Vibe")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            HStack {
                ForEach(viewModel.moods, id: \.self) { mood in
                    Text(mood)
                        .font(.system(size: 30))
                        .padding(8)
                        .background(viewModel.selectedMood == mood ? DesignSystem.Colors.primary.opacity(0.2) : Color.clear)
                        .clipShape(Circle())
                        .onTapGesture {
                            viewModel.selectedMood = mood
                        }
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.secondary.opacity(0.3)))
        }
    }
    
    private var notesSection: some View {
        VStack(alignment: .leading) {
            Text("Notes")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            TextEditor(text: $viewModel.notes)
                .frame(height: 100)
                .padding(4)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.secondary.opacity(0.5)))
            
            Text("\(viewModel.notes.count) / 120")
                .frame(maxWidth: .infinity, alignment: .trailing)
                .font(.caption)
                .foregroundStyle(viewModel.notes.count >= 120 ? .red : .secondary)
        }
    }
    
    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button {
                if viewModel.saveTrip() {
                    dismiss()
                }
            } label: {
                Text("Save Trip")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(viewModel.isSaveDisabled ? Color.gray : Color.blue)
                    .foregroundStyle(.white)
                    .fontWeight(.bold)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(viewModel.isSaveDisabled)

            Button("Cancel", role: .cancel) {
                dismiss()
            }
            .padding(.bottom, 20)
        }
    }
}

#Preview {
    AddTripView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
