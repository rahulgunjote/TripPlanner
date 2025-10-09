import SwiftUI
import SwiftData
import MapKit

struct TripListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Trip.startDate, order: .reverse) private var trips: [Trip]
    @State private var showingCreateTrip = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                if trips.isEmpty {
                    EmptyTripListView()
                } else {
                    TripList(trips: trips, modelContext: modelContext)
                }
                
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        FloatingActionButton {
                            showingCreateTrip = true
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("My Trips")
            .sheet(isPresented: $showingCreateTrip) {
                CreateTripView()
            }
        }
    }
}

struct TripList: View {
    let trips: [Trip]
    let modelContext: ModelContext
    
    var body: some View {
        List {
            ForEach(trips) { trip in
                NavigationLink(destination: TripDetailView(trip: trip)) {
                    TripRowView(trip: trip)
                }
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                .listRowSeparator(.hidden)
            }
            .onDelete(perform: deleteTrips)
            
            // Spacer for floating button
            Color.clear
                .frame(height: 80)
                .listRowSeparator(.hidden)
        }
        .listStyle(.plain)
    }
    
    private func deleteTrips(at offsets: IndexSet) {
        for index in offsets {
            let tripToDelete = trips[index]
            modelContext.delete(tripToDelete)
        }
        try? modelContext.save()
    }
}

struct TripRowView: View {
    let trip: Trip
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Location Map Thumbnail or Placeholder
            Group {
                if let latitude = trip.latitude, let longitude = trip.longitude {
                    MapThumbnailView(latitude: latitude, longitude: longitude)
                } else {
                    Image(systemName: "map")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.gray)
                        .padding(20)
                }
            }
            .frame(width: 80, height: 80)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
            .clipped()
            
            // Trip Details
            VStack(alignment: .leading, spacing: 6) {
                Text(trip.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Label(trip.location, systemImage: "location.fill")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Label(trip.dateRangeString, systemImage: "calendar")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if !trip.travellerIDs.isEmpty {
                    Label("\(trip.travellerIDs.count) traveller(s)", systemImage: "person.2.fill")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct EmptyTripListView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "airplane.departure")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(.gray)
            
            Text("No trips yet")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Start planning your next adventure by creating a new trip")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }
}

struct FloatingActionButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "plus")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(width: 60, height: 60)
                .background(Color.blue)
                .clipShape(Circle())
                .shadow(color: .blue.opacity(0.4), radius: 10, x: 0, y: 5)
        }
    }
}

struct MapThumbnailView: View {
    let latitude: Double
    let longitude: Double
    
    @State private var region: MKCoordinateRegion
    
    init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
        _region = State(initialValue: MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        ))
    }
    
    var body: some View {
        Map(position: .constant(.region(region))) {
            Marker("", coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
        }
        .disabled(true)
    }
}

#Preview {
    TripListView()
        .modelContainer(for: Trip.self, inMemory: true)
}

