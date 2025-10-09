import SwiftUI
import MapKit

struct LocationPickerView: View {
    @Environment(\.dismiss) private var dismiss
    
    @Binding var locationName: String
    @Binding var latitude: Double?
    @Binding var longitude: Double?
    
    @State private var position: MapCameraPosition
    @State private var selectedCoordinate: CLLocationCoordinate2D?
    @State private var searchText = ""
    @State private var searchResults: [MKMapItem] = []
    @State private var searchTask: Task<Void, Never>?
    
    init(locationName: Binding<String>, latitude: Binding<Double?>, longitude: Binding<Double?>) {
        self._locationName = locationName
        self._latitude = latitude
        self._longitude = longitude
        
        if let lat = latitude.wrappedValue, let lon = longitude.wrappedValue {
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            _selectedCoordinate = State(initialValue: coordinate)
            _position = State(initialValue: .region(MKCoordinateRegion(
                center: coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )))
        } else {
            _position = State(initialValue: .automatic)
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    TextField("Search for a location", text: $searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                        .onChange(of: searchText) { oldValue, newValue in
                            // Cancel previous search task
                            searchTask?.cancel()
                            
                            // Clear results if search text is empty
                            guard !newValue.isEmpty else {
                                searchResults = []
                                return
                            }
                            
                            // Debounce search with 0.5 second delay
                            searchTask = Task {
                                try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
                                
                                if !Task.isCancelled {
                                    await searchLocation(query: newValue)
                                }
                            }
                        }
                    if !searchText.isEmpty {
                        Button(action: {
                            searchText = ""
                            searchResults = []
                            searchTask?.cancel()
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                
                // Search results
                if !searchResults.isEmpty {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 0) {
                            ForEach(searchResults, id: \.self) { item in
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
                                    .padding()
                                }
                                Divider()
                            }
                        }
                    }
                    .frame(maxHeight: 200)
                    .background(Color(.systemBackground))
                }
                
                // Map
                Map(position: $position) {
                    if let coordinate = selectedCoordinate {
                        Marker("Selected Location", coordinate: coordinate)
                    }
                }
                .onMapCameraChange { context in
                    // Update selected coordinate when map is moved
                    if selectedCoordinate == nil {
                        selectedCoordinate = context.region.center
                    }
                }
                .overlay(alignment: .center) {
                    if selectedCoordinate != nil {
                        Image(systemName: "mappin.circle.fill")
                            .font(.largeTitle)
                            .foregroundColor(.red)
                            .offset(y: -20)
                    }
                }
            }
            .navigationTitle("Select Location")
            .navigationBarTitleDisplayMode(.inline)
            .onDisappear {
                searchTask?.cancel()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        if let coordinate = selectedCoordinate {
                            latitude = coordinate.latitude
                            longitude = coordinate.longitude
                            if locationName.isEmpty && !searchResults.isEmpty {
                                locationName = searchResults.first?.name ?? ""
                            }
                        }
                        dismiss()
                    }
                    .disabled(selectedCoordinate == nil)
                }
            }
        }
    }
    
    private func searchLocation(query: String) async {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        
        let search = MKLocalSearch(request: request)
        
        do {
            let response = try await search.start()
            await MainActor.run {
                searchResults = response.mapItems
            }
        } catch {
            print("Search error: \(error.localizedDescription)")
            await MainActor.run {
                searchResults = []
            }
        }
    }
    
    private func selectLocation(_ item: MKMapItem) {
        searchTask?.cancel()
        selectedCoordinate = item.placemark.coordinate
        locationName = item.name ?? ""
        searchText = ""
        searchResults = []
        
        position = .region(MKCoordinateRegion(
            center: item.placemark.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        ))
    }
}

#Preview {
    LocationPickerView(
        locationName: .constant(""),
        latitude: .constant(nil),
        longitude: .constant(nil)
    )
}

