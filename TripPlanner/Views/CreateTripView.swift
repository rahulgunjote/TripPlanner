import SwiftUI
import SwiftData
import MapKit

struct CreateTripView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Traveller.name) private var allTravellersInDB: [Traveller]
    
    @State private var tripName = ""
    @State private var location = ""
    @State private var startDate = Date()
    @State private var endDate = Date()
    @State private var notes = ""
    @State private var selectedTravellers: Set<UUID> = []
    @State private var showingTravellerSelection = false
    @State private var latitude: Double?
    @State private var longitude: Double?
    @State private var showingLocationPicker = false
    @State private var locationSearchResults: [MKMapItem] = []
    @State private var isSearching = false
    
    var selectedTravellersArray: [Traveller] {
        allTravellersInDB.filter { selectedTravellers.contains($0.id) }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Trip Details") {
                    TextField("Trip Name", text: $tripName)
                    
                    DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                    DatePicker("End Date", selection: $endDate, displayedComponents: .date)
                }
                
                Section("Location") {
                    TextField("Location Name", text: $location)
                        .onChange(of: location) { _, newValue in
                            if !newValue.isEmpty {
                                searchLocation(query: newValue)
                            } else {
                                locationSearchResults = []
                            }
                        }
                    
                    // Show search results
                    if !locationSearchResults.isEmpty {
                        ForEach(locationSearchResults, id: \.self) { item in
                            Button(action: {
                                selectLocation(item)
                            }) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(item.name ?? "Unknown")
                                        .font(.body)
                                        .foregroundColor(.primary)
                                    if let address = item.placemark.title {
                                        Text(address)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                        }
                    }
                    
                    if let latitude = latitude, let longitude = longitude {
                        HStack {
                            Text("Coordinates:")
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("\(latitude, specifier: "%.4f"), \(longitude, specifier: "%.4f")")
                                .font(.caption)
                        }
                        
                        MapPreviewView(latitude: latitude, longitude: longitude)
                            .frame(height: 200)
                            .cornerRadius(8)
                    }
                    
                    Button(action: {
                        showingLocationPicker = true
                    }) {
                        Label(latitude == nil ? "Set Location on Map" : "Change Location", systemImage: "map")
                    }
                }
                
                Section {
                    if selectedTravellersArray.isEmpty {
                        Text("No travellers selected")
                            .foregroundColor(.secondary)
                            .font(.subheadline)
                    } else {
                        ForEach(selectedTravellersArray) { traveller in
                            HStack {
                                Image(systemName: traveller.travellerType == .adult ? "person.circle.fill" : "figure.and.child.holdinghands")
                                    .foregroundColor(.blue)
                                VStack(alignment: .leading) {
                                    HStack {
                                        Text(traveller.name)
                                            .font(.body)
                                        Text("(\(traveller.travellerType.rawValue))")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    if !traveller.email.isEmpty {
                                        Text(traveller.email)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                Spacer()
                                Button(role: .destructive) {
                                    selectedTravellers.remove(traveller.id)
                                } label: {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                }
                            }
                        }
                    }
                    
                    Button(action: {
                        showingTravellerSelection = true
                    }) {
                        Label("Select Travellers", systemImage: "person.2.badge.gearshape")
                    }
                } header: {
                    Text("Trip Travellers (\(selectedTravellersArray.count))")
                } footer: {
                    if allTravellersInDB.isEmpty {
                        Text("Go to Travellers tab to add travellers that can be reused across trips")
                            .font(.caption)
                    }
                }
                
                Section("Itinerary") {
                    HStack {
                        Image(systemName: "list.bullet.clipboard")
                            .foregroundColor(.blue)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Plan Your Activities")
                                .font(.body)
                            Text("Add itinerary after saving the trip")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 4)
                }
                
                Section("Notes") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                }
            }
            .navigationTitle("Create Trip")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveTrip()
                        dismiss()
                    }
                    .disabled(tripName.isEmpty || location.isEmpty)
                }
            }
            .sheet(isPresented: $showingTravellerSelection) {
                TravellerSelectionView(
                    allTravellers: allTravellersInDB,
                    selectedTravellerIDs: $selectedTravellers
                )
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
    
    private func saveTrip() {
        let trip = Trip(
            name: tripName,
            startDate: startDate,
            endDate: endDate,
            location: location,
            latitude: latitude,
            longitude: longitude,
            notes: notes
        )
        
        // Add selected travellers to the trip
        for traveller in selectedTravellersArray {
            trip.travellerIDs.append(traveller.id.uuidString)
        }
        
        modelContext.insert(trip)
        try? modelContext.save()
    }
    
    private func searchLocation(query: String) {
        guard !isSearching else { return }
        isSearching = true
        
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = query
        
        let search = MKLocalSearch(request: searchRequest)
        search.start { response, error in
            isSearching = false
            
            guard let response = response else {
                locationSearchResults = []
                return
            }
            
            locationSearchResults = Array(response.mapItems.prefix(5))
        }
    }
    
    private func selectLocation(_ item: MKMapItem) {
        location = item.name ?? ""
        latitude = item.placemark.coordinate.latitude
        longitude = item.placemark.coordinate.longitude
        locationSearchResults = []
    }
}

struct TravellerSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    let allTravellers: [Traveller]
    @Binding var selectedTravellerIDs: Set<UUID>
    
    var body: some View {
        NavigationStack {
            List {
                if allTravellers.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "person.2.slash")
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                        Text("No Travellers Available")
                            .font(.headline)
                        Text("Go to Travellers tab to create travellers")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                } else {
                    ForEach(allTravellers) { traveller in
                        HStack {
                            Image(systemName: traveller.travellerType == .adult ? "person.circle.fill" : "figure.and.child.holdinghands")
                                .foregroundColor(.blue)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text(traveller.name)
                                        .font(.body)
                                    Text("(\(traveller.travellerType.rawValue))")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                if !traveller.email.isEmpty {
                                    Text(traveller.email)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            Spacer()
                            
                            if selectedTravellerIDs.contains(traveller.id) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.blue)
                            } else {
                                Image(systemName: "circle")
                                    .foregroundColor(.gray)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if selectedTravellerIDs.contains(traveller.id) {
                                selectedTravellerIDs.remove(traveller.id)
                            } else {
                                selectedTravellerIDs.insert(traveller.id)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Select Travellers")
            .navigationBarTitleDisplayMode(.inline)
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
    CreateTripView()
        .modelContainer(for: Trip.self, inMemory: true)
}

