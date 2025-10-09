import SwiftUI
import SwiftData

struct ItineraryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Bindable var trip: Trip
    @State private var showingAddItinerary = false
    @State private var selectedItem: ItineraryItem?
    
    var groupedItems: [(Date, [ItineraryItem])] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: trip.itineraryItems) { item in
            calendar.startOfDay(for: item.date)
        }
        return grouped.sorted { $0.key < $1.key }
    }
    
    var body: some View {
        Group {
            if trip.itineraryItems.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "list.bullet.clipboard")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.gray)
                    
                    Text("No itinerary items")
                        .font(.title3)
                        .fontWeight(.semibold)
                    
                    Text("Add activities, places to visit, and plans for your trip")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    
                    Button(action: {
                        showingAddItinerary = true
                    }) {
                        Label("Add Itinerary Item", systemImage: "plus.circle.fill")
                            .font(.headline)
                    }
                    .buttonStyle(.borderedProminent)
                }
            } else {
                List {
                    ForEach(groupedItems, id: \.0) { date, items in
                        Section(header: Text(formatDate(date))) {
                            ForEach(items) { item in
                                ItineraryRowView(item: item)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        selectedItem = item
                                    }
                                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                        Button(role: .destructive) {
                                            deleteItem(item)
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
        .navigationTitle("Itinerary")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showingAddItinerary = true
                }) {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddItinerary) {
            AddItineraryItemView(trip: trip)
        }
        .sheet(item: $selectedItem) { item in
            EditItineraryItemView(item: item)
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d, yyyy"
        return formatter.string(from: date)
    }
    
    private func deleteItem(_ item: ItineraryItem) {
        withAnimation {
            if let index = trip.itineraryItems.firstIndex(where: { $0.id == item.id }) {
                trip.itineraryItems.remove(at: index)
                modelContext.delete(item)
                try? modelContext.save()
            }
        }
    }
}

struct ItineraryRowView: View {
    @Bindable var item: ItineraryItem
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Button(action: {
                item.isCompleted.toggle()
            }) {
                Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(item.isCompleted ? .green : .gray)
                    .font(.title3)
            }
            .buttonStyle(PlainButtonStyle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.headline)
                    .strikethrough(item.isCompleted)
                    .foregroundColor(item.isCompleted ? .secondary : .primary)
                
                if let timeRange = item.timeRangeString {
                    Label(timeRange, systemImage: "clock")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if !item.location.isEmpty {
                    Label(item.location, systemImage: "location.fill")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if !item.itemDescription.isEmpty {
                    Text(item.itemDescription)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack {
        ItineraryView(trip: Trip(
            name: "Sample Trip",
            startDate: Date(),
            endDate: Date(),
            location: "Paris"
        ))
        .modelContainer(for: Trip.self, inMemory: true)
    }
}

