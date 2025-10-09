import SwiftUI
import SwiftData
import MapKit

struct TripDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var allTravellersInDB: [Traveller]
    
    @Bindable var trip: Trip
    @State private var showingAddExpense = false
    @State private var selectedExpense: Expense?
    @State private var showingTravellersList = false
    @State private var showingAddTraveller = false
    @State private var showingExpenseReport = false
    
    var tripTravellersArray: [Traveller] {
        allTravellersInDB.filter { trip.travellerIDs.contains($0.id.uuidString) }
    }
    
    var adultsCount: Int {
        tripTravellersArray.filter { $0.travellerType == .adult }.count
    }
    
    var childrenCount: Int {
        tripTravellersArray.filter { $0.travellerType == .child }.count
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 16) {
                    // Trip Name
                    Text(trip.name)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    // Location
                    Label(trip.location, systemImage: "location.fill")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    // Dates
                    Label(trip.dateRangeString, systemImage: "calendar")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    // Map if coordinates available
                    if let latitude = trip.latitude, let longitude = trip.longitude {
                        MapPreviewView(latitude: latitude, longitude: longitude)
                            .frame(height: 200)
                            .cornerRadius(12)
                    }
                    
                    // Notes
                    if !trip.notes.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Notes")
                                .font(.headline)
                            Text(trip.notes)
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                    
                    Divider()
                    
                    // Trip Travellers Button
                    Button(action: {
                        showingTravellersList = true
                    }) {
                        HStack {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Trip Travellers")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                HStack(spacing: 16) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "person.fill")
                                            .font(.caption)
                                        Text("\(adultsCount) Adult\(adultsCount != 1 ? "s" : "")")
                                            .font(.subheadline)
                                    }
                                    
                                    HStack(spacing: 4) {
                                        Image(systemName: "figure.and.child.holdinghands")
                                            .font(.caption)
                                        Text("\(childrenCount) Child\(childrenCount != 1 ? "ren" : "")")
                                            .font(.subheadline)
                                    }
                                }
                                .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Divider()
                    
                    // Itinerary Summary
                    NavigationLink(destination: ItineraryView(trip: trip)) {
                        HStack {
                            Image(systemName: "list.bullet.clipboard")
                                .font(.title2)
                                .foregroundColor(.blue)
                                .frame(width: 30)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Itinerary")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                HStack {
                                    Text("\(trip.itineraryItems.count) items")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text("•")
                                        .foregroundColor(.secondary)
                                    Text("Tap to edit")
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                }
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                    
                    Divider()
                    
                    // Expenses Section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Expenses")
                                .font(.headline)
                            
                            Spacer()
                            
                            Button(action: {
                                showingExpenseReport = true
                            }) {
                                Label("Report", systemImage: "chart.bar.doc.horizontal")
                                    .font(.subheadline)
                            }
                            
                            Button(action: {
                                showingAddExpense = true
                            }) {
                                Label("Add", systemImage: "plus.circle.fill")
                                    .font(.subheadline)
                            }
                        }
                        
                        // Total Expenses
                        HStack {
                            Text("Total:")
                                .font(.title3)
                                .fontWeight(.semibold)
                            Spacer()
                            Text("$\(trip.totalExpenses, specifier: "%.2f")")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                        }
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(12)
                        
                        // Expense List
                        if trip.expenses.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "dollarsign.circle")
                                    .font(.system(size: 50))
                                    .foregroundColor(.gray)
                                
                                Text("No expenses yet")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                Button(action: {
                                    showingAddExpense = true
                                }) {
                                    Label("Add First Expense", systemImage: "plus")
                                }
                                .buttonStyle(.bordered)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 30)
                        } else {
                            ExpenseListView(
                                expenses: trip.expenses,
                                onEdit: { expense in
                                    selectedExpense = expense
                                },
                                onDelete: { expense in
                                    deleteExpense(expense)
                                }
                            )
                        }
                    }
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingAddExpense) {
            AddExpenseView(trip: trip, travellers: tripTravellersArray)
        }
        .sheet(item: $selectedExpense) { expense in
            EditExpenseView(expense: expense, trip: trip, travellers: tripTravellersArray)
        }
        .sheet(isPresented: $showingTravellersList) {
            TravellersListView(trip: trip, modelContext: modelContext, allTravellersInDB: allTravellersInDB)
        }
        .sheet(isPresented: $showingAddTraveller) {
            AddTravellerToTripView(trip: trip, modelContext: modelContext, allTravellersInDB: allTravellersInDB)
                .presentationDetents([.medium, .large])
        }
        .sheet(isPresented: $showingExpenseReport) {
            ExpenseReportView(trip: trip, travellers: tripTravellersArray)
        }
    }
    
    private func deleteExpense(_ expense: Expense) {
        withAnimation {
            if let index = trip.expenses.firstIndex(where: { $0.id == expense.id }) {
                trip.expenses.remove(at: index)
                modelContext.delete(expense)
                try? modelContext.save()
            }
        }
    }
}

struct ExpenseListView: View {
    let expenses: [Expense]
    let onEdit: (Expense) -> Void
    let onDelete: (Expense) -> Void
    
    var sortedExpenses: [Expense] {
        expenses.sorted { $0.date > $1.date }
    }
    
    var body: some View {
        VStack(spacing: 8) {
            ForEach(sortedExpenses) { expense in
                ExpenseRowView(expense: expense)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        onEdit(expense)
                    }
                    .contextMenu {
                        Button(role: .destructive) {
                            onDelete(expense)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
            }
        }
    }
}

struct ExpenseRowView: View {
    let expense: Expense
    
    var body: some View {
        HStack {
            Image(systemName: expense.category.icon)
                .font(.title3)
                .foregroundColor(.blue)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(expense.title)
                    .font(.body)
                    .fontWeight(.medium)
                
                HStack {
                    Text(expense.category.rawValue)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if !expense.paidBy.isEmpty {
                        Text("•")
                            .foregroundColor(.secondary)
                        Text(expense.paidBy)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Text(formatDate(expense.date))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text("$\(expense.amount, specifier: "%.2f")")
                .font(.headline)
                .foregroundColor(.primary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

struct TravellersListView: View {
    @Environment(\.dismiss) private var dismiss
    let trip: Trip
    let modelContext: ModelContext
    let allTravellersInDB: [Traveller]
    @State private var showingAddTraveller = false
    
    var tripTravellersArray: [Traveller] {
        allTravellersInDB.filter { trip.travellerIDs.contains($0.id.uuidString) }
    }
    
    var adults: [Traveller] {
        tripTravellersArray.filter { $0.travellerType == .adult }
    }
    
    var children: [Traveller] {
        tripTravellersArray.filter { $0.travellerType == .child }
    }
    
    var body: some View {
        NavigationStack {
            List {
                if !adults.isEmpty {
                    Section("Adults (\(adults.count))") {
                        ForEach(adults) { traveller in
                            TravellerRowView(traveller: traveller)
                        }
                        .onDelete { indexSet in
                            deleteAdults(at: indexSet)
                        }
                    }
                }
                
                if !children.isEmpty {
                    Section("Children (\(children.count))") {
                        ForEach(children) { traveller in
                            TravellerRowView(traveller: traveller)
                        }
                        .onDelete { indexSet in
                            deleteChildren(at: indexSet)
                        }
                    }
                }
                
                if tripTravellersArray.isEmpty {
                    Section {
                        VStack(spacing: 12) {
                            Image(systemName: "person.2")
                                .font(.system(size: 50))
                                .foregroundColor(.gray)
                            
                            Text("No travellers added")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 30)
                    }
                }
            }
            .navigationTitle("Trip Travellers")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        showingAddTraveller = true
                    }) {
                        Label("Add", systemImage: "person.badge.plus")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingAddTraveller) {
                AddTravellerToTripView(trip: trip, modelContext: modelContext, allTravellersInDB: allTravellersInDB)
                    .presentationDetents([.medium, .large])
            }
        }
    }
    
    private func deleteAdults(at offsets: IndexSet) {
        for index in offsets {
            let traveller = adults[index]
            if let idx = trip.travellerIDs.firstIndex(of: traveller.id.uuidString) {
                trip.travellerIDs.remove(at: idx)
            }
        }
        try? modelContext.save()
    }
    
    private func deleteChildren(at offsets: IndexSet) {
        for index in offsets {
            let traveller = children[index]
            if let idx = trip.travellerIDs.firstIndex(of: traveller.id.uuidString) {
                trip.travellerIDs.remove(at: idx)
            }
        }
        try? modelContext.save()
    }
}

struct TravellerRowView: View {
    let traveller: Traveller
    
    var body: some View {
        HStack {
            Image(systemName: traveller.travellerType == .adult ? "person.circle.fill" : "figure.and.child.holdinghands")
                .font(.title2)
                .foregroundColor(.blue)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(traveller.name)
                    .font(.body)
                if !traveller.email.isEmpty {
                    Text(traveller.email)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                if !traveller.phoneNumber.isEmpty {
                    Text(traveller.phoneNumber)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

struct AddTravellerToTripView: View {
    @Environment(\.dismiss) private var dismiss
    
    let trip: Trip
    let modelContext: ModelContext
    let allTravellersInDB: [Traveller]
    
    @State private var selectedTravellerIDs: Set<UUID> = []
    
    var availableTravellersNotInTrip: [Traveller] {
        allTravellersInDB.filter { !trip.travellerIDs.contains($0.id.uuidString) }
    }
    
    var body: some View {
        NavigationStack {
            List {
                if availableTravellersNotInTrip.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "person.2.slash")
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                        Text("All travellers already added")
                            .font(.headline)
                        Text("Go to Travellers tab to create more travellers")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                } else {
                    ForEach(availableTravellersNotInTrip) { traveller in
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
            .navigationTitle("Add Travellers")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        addTravellersToTrip()
                    }
                    .disabled(selectedTravellerIDs.isEmpty)
                }
            }
        }
    }
    
    private func addTravellersToTrip() {
        for travellerID in selectedTravellerIDs {
            if !trip.travellerIDs.contains(travellerID.uuidString) {
                trip.travellerIDs.append(travellerID.uuidString)
            }
        }
        try? modelContext.save()
        dismiss()
    }
}

struct ExpenseReportView: View {
    @Environment(\.dismiss) private var dismiss
    let trip: Trip
    let travellers: [Traveller]
    
    // Calculate traveller shares
    var travellerShares: [(traveller: Traveller, share: Double, paid: Double, balance: Double)] {
        var shares: [(traveller: Traveller, share: Double, paid: Double, balance: Double)] = []
        
        for traveller in travellers {
            let travellerIdStr = traveller.id.uuidString
            
            // Calculate how much this traveller should pay (their share)
            var travellerShare: Double = 0
            for expense in trip.expenses {
                if expense.sharedByMemberIds.contains(travellerIdStr) {
                    let shareCount = max(expense.sharedByMemberIds.count, 1)
                    travellerShare += expense.amount / Double(shareCount)
                }
            }
            
            // Calculate how much this traveller paid
            let travellerPaid = trip.expenses
                .filter { $0.paidBy == traveller.name }
                .reduce(0) { $0 + $1.amount }
            
            // Calculate balance (positive = owed to them, negative = they owe)
            let balance = travellerPaid - travellerShare
            
            shares.append((traveller: traveller, share: travellerShare, paid: travellerPaid, balance: balance))
        }
        
        return shares.sorted { $0.traveller.name < $1.traveller.name }
    }
    
    var totalExpenses: Double {
        trip.expenses.reduce(0) { $0 + $1.amount }
    }
    
    var body: some View {
        NavigationStack {
            List {
                // Total Summary
                Section {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Total Expenses")
                                .font(.headline)
                            Text("\(trip.expenses.count) expenses")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Text("$\(totalExpenses, specifier: "%.2f")")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                    }
                    .padding(.vertical, 8)
                }
                
                // Traveller Shares
                Section("Traveller Breakdown") {
                    if travellerShares.isEmpty {
                        Text("No travellers to calculate shares")
                            .foregroundColor(.secondary)
                            .font(.subheadline)
                    } else {
                        ForEach(travellerShares, id: \.traveller.id) { item in
                            VStack(spacing: 12) {
                                // Traveller header
                                HStack {
                                    Image(systemName: item.traveller.travellerType == .adult ? "person.circle.fill" : "figure.and.child.holdinghands")
                                        .foregroundColor(.blue)
                                    Text(item.traveller.name)
                                        .font(.headline)
                                    Spacer()
                                }
                                
                                // Financial details
                                VStack(spacing: 6) {
                                    HStack {
                                        Text("Share:")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                        Spacer()
                                        Text("$\(item.share, specifier: "%.2f")")
                                            .font(.subheadline)
                                    }
                                    
                                    HStack {
                                        Text("Paid:")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                        Spacer()
                                        Text("$\(item.paid, specifier: "%.2f")")
                                            .font(.subheadline)
                                    }
                                    
                                    Divider()
                                    
                                    HStack {
                                        Text("Balance:")
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                        Spacer()
                                        Text("$\(abs(item.balance), specifier: "%.2f")")
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                            .foregroundColor(item.balance >= 0 ? .green : .red)
                                        Text(item.balance >= 0 ? "(owed to them)" : "(they owe)")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .padding(12)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
                
                // Expense Details
                Section("Expense Details") {
                    if trip.expenses.isEmpty {
                        Text("No expenses recorded")
                            .foregroundColor(.secondary)
                            .font(.subheadline)
                    } else {
                        ForEach(trip.expenses.sorted { $0.date > $1.date }) { expense in
                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    Text(expense.title)
                                        .font(.body)
                                        .fontWeight(.medium)
                                    Spacer()
                                    Text("$\(expense.amount, specifier: "%.2f")")
                                        .font(.body)
                                        .fontWeight(.semibold)
                                }
                                
                                HStack {
                                    if !expense.paidBy.isEmpty {
                                        Text("Paid by: \(expense.paidBy)")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    if !expense.sharedByMemberIds.isEmpty {
                                        Text("• Shared by \(expense.sharedByMemberIds.count)")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            .navigationTitle("Expense Report")
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
    NavigationStack {
        TripDetailView(trip: Trip(
            name: "European Adventure",
            startDate: Date(),
            endDate: Date().addingTimeInterval(86400 * 7),
            location: "Paris, France",
            notes: "Visit the Eiffel Tower and Louvre Museum"
        ))
        .modelContainer(for: [Trip.self, Traveller.self], inMemory: true)
    }
}
