import SwiftUI
import SwiftData

struct AddItineraryItemView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Bindable var trip: Trip
    
    @State private var title = ""
    @State private var itemDescription = ""
    @State private var date = Date()
    @State private var hasStartTime = false
    @State private var startTime = Date()
    @State private var hasEndTime = false
    @State private var endTime = Date()
    @State private var location = ""
    @State private var notes = ""
    @State private var latitude: Double?
    @State private var longitude: Double?
    @State private var showingLocationPicker = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Title", text: $title)
                    TextField("Description", text: $itemDescription)
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                }
                
                Section("Time") {
                    Toggle("Has Start Time", isOn: $hasStartTime)
                    if hasStartTime {
                        DatePicker("Start Time", selection: $startTime, displayedComponents: .hourAndMinute)
                    }
                    
                    Toggle("Has End Time", isOn: $hasEndTime)
                    if hasEndTime {
                        DatePicker("End Time", selection: $endTime, displayedComponents: .hourAndMinute)
                    }
                }
                
                Section("Location") {
                    TextField("Location", text: $location)
                    
                    if let latitude = latitude, let longitude = longitude {
                        HStack {
                            Text("Coordinates:")
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("\(latitude, specifier: "%.4f"), \(longitude, specifier: "%.4f")")
                                .font(.caption)
                        }
                        
                        MapPreviewView(latitude: latitude, longitude: longitude)
                            .frame(height: 150)
                            .cornerRadius(8)
                    }
                    
                    Button(action: {
                        showingLocationPicker = true
                    }) {
                        Label(latitude == nil ? "Set Location" : "Change Location", systemImage: "map")
                    }
                }
                
                Section("Notes") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 80)
                }
            }
            .navigationTitle("Add Itinerary Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveItem()
                    }
                    .disabled(title.isEmpty)
                }
            }
            .sheet(isPresented: $showingLocationPicker) {
                LocationPickerView(
                    locationName: $location,
                    latitude: $latitude,
                    longitude: $longitude
                )
            }
        }
    }
    
    private func saveItem() {
        let item = ItineraryItem(
            title: title,
            itemDescription: itemDescription,
            date: date,
            startTime: hasStartTime ? startTime : nil,
            endTime: hasEndTime ? endTime : nil,
            location: location,
            latitude: latitude,
            longitude: longitude,
            notes: notes
        )
        
        trip.itineraryItems.append(item)
        try? modelContext.save()
        dismiss()
    }
}

struct EditItineraryItemView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Bindable var item: ItineraryItem
    
    @State private var title: String
    @State private var itemDescription: String
    @State private var date: Date
    @State private var hasStartTime: Bool
    @State private var startTime: Date
    @State private var hasEndTime: Bool
    @State private var endTime: Date
    @State private var location: String
    @State private var notes: String
    @State private var latitude: Double?
    @State private var longitude: Double?
    @State private var showingLocationPicker = false
    
    init(item: ItineraryItem) {
        self.item = item
        _title = State(initialValue: item.title)
        _itemDescription = State(initialValue: item.itemDescription)
        _date = State(initialValue: item.date)
        _hasStartTime = State(initialValue: item.startTime != nil)
        _startTime = State(initialValue: item.startTime ?? Date())
        _hasEndTime = State(initialValue: item.endTime != nil)
        _endTime = State(initialValue: item.endTime ?? Date())
        _location = State(initialValue: item.location)
        _notes = State(initialValue: item.notes)
        _latitude = State(initialValue: item.latitude)
        _longitude = State(initialValue: item.longitude)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Title", text: $title)
                    TextField("Description", text: $itemDescription)
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                }
                
                Section("Time") {
                    Toggle("Has Start Time", isOn: $hasStartTime)
                    if hasStartTime {
                        DatePicker("Start Time", selection: $startTime, displayedComponents: .hourAndMinute)
                    }
                    
                    Toggle("Has End Time", isOn: $hasEndTime)
                    if hasEndTime {
                        DatePicker("End Time", selection: $endTime, displayedComponents: .hourAndMinute)
                    }
                }
                
                Section("Location") {
                    TextField("Location", text: $location)
                    
                    if let latitude = latitude, let longitude = longitude {
                        HStack {
                            Text("Coordinates:")
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("\(latitude, specifier: "%.4f"), \(longitude, specifier: "%.4f")")
                                .font(.caption)
                        }
                        
                        MapPreviewView(latitude: latitude, longitude: longitude)
                            .frame(height: 150)
                            .cornerRadius(8)
                    }
                    
                    Button(action: {
                        showingLocationPicker = true
                    }) {
                        Label(latitude == nil ? "Set Location" : "Change Location", systemImage: "map")
                    }
                }
                
                Section("Notes") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 80)
                }
            }
            .navigationTitle("Edit Itinerary Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveChanges()
                    }
                    .disabled(title.isEmpty)
                }
            }
            .sheet(isPresented: $showingLocationPicker) {
                LocationPickerView(
                    locationName: $location,
                    latitude: $latitude,
                    longitude: $longitude
                )
            }
        }
    }
    
    private func saveChanges() {
        item.title = title
        item.itemDescription = itemDescription
        item.date = date
        item.startTime = hasStartTime ? startTime : nil
        item.endTime = hasEndTime ? endTime : nil
        item.location = location
        item.latitude = latitude
        item.longitude = longitude
        item.notes = notes
        
        try? modelContext.save()
        dismiss()
    }
}

#Preview {
    AddItineraryItemView(trip: Trip(
        name: "Sample Trip",
        startDate: Date(),
        endDate: Date(),
        location: "Paris"
    ))
    .modelContainer(for: Trip.self, inMemory: true)
}

