import SwiftUI
import SwiftData

struct AddExpenseView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Bindable var trip: Trip
    let travellers: [Traveller]
    
    @State private var title = ""
    @State private var amount = ""
    @State private var currency = ""
    @State private var category: ExpenseCategory = .other
    @State private var date = Date()
    @State private var notes = ""
    @State private var paidBy = ""
    @State private var selectedTravellerIds: Set<String> = []
    
    init(trip: Trip, travellers: [Traveller]) {
        self.trip = trip
        self.travellers = travellers
        // Set default currency based on device locale
        _currency = State(initialValue: Locale.current.currency?.identifier ?? "USD")
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Expense Details") {
                    TextField("Title", text: $title)
                    
                    HStack {
                        Text("$")
                        TextField("Amount", text: $amount)
                            .keyboardType(.decimalPad)
                    }
                    
                    Picker("Category", selection: $category) {
                        ForEach(ExpenseCategory.allCases, id: \.self) { category in
                            Label(category.rawValue, systemImage: category.icon)
                                .tag(category)
                        }
                    }
                    
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                }
                
                Section("Additional Information") {
                    Picker("Paid By", selection: $paidBy) {
                        Text("Not specified").tag("")
                        ForEach(travellers) { traveller in
                            Text(traveller.name).tag(traveller.name)
                        }
                    }
                    
                    TextField("Currency", text: $currency)
                }
                
                Section {
                    if travellers.isEmpty {
                        Text("No travellers to share expense with")
                            .foregroundColor(.secondary)
                            .font(.subheadline)
                    } else {
                        ForEach(travellers) { traveller in
                            Button(action: {
                                toggleTravellerSelection(traveller)
                            }) {
                                HStack {
                                    Image(systemName: selectedTravellerIds.contains(traveller.id.uuidString) ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(selectedTravellerIds.contains(traveller.id.uuidString) ? .blue : .gray)
                                    
                                    VStack(alignment: .leading) {
                                        Text(traveller.name)
                                            .foregroundColor(.primary)
                                        Text(traveller.travellerType.rawValue)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                }
                            }
                        }
                        
                        if !travellers.isEmpty {
                            HStack {
                                Spacer()
                                Button(selectedTravellerIds.count == travellers.count ? "Deselect All" : "Select All") {
                                    if selectedTravellerIds.count == travellers.count {
                                        selectedTravellerIds.removeAll()
                                    } else {
                                        selectedTravellerIds = Set(travellers.map { $0.id.uuidString })
                                    }
                                }
                                .font(.subheadline)
                                Spacer()
                            }
                        }
                    }
                } header: {
                    Text("Shared By")
                } footer: {
                    Text("Select travellers who will share this expense")
                }
                
                Section("Notes") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 80)
                }
            }
            .navigationTitle("Add Expense")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveExpense()
                    }
                    .disabled(title.isEmpty || amount.isEmpty || Double(amount) == nil)
                }
            }
        }
    }
    
    private func saveExpense() {
        guard let amountValue = Double(amount) else { return }
        
        let expense = Expense(
            title: title,
            amount: amountValue,
            currency: currency,
            category: category,
            date: date,
            notes: notes,
            paidBy: paidBy,
            sharedByMemberIds: Array(selectedTravellerIds)
        )
        
        trip.expenses.append(expense)
        try? modelContext.save()
        dismiss()
    }
    
    private func toggleTravellerSelection(_ traveller: Traveller) {
        let travellerId = traveller.id.uuidString
        if selectedTravellerIds.contains(travellerId) {
            selectedTravellerIds.remove(travellerId)
        } else {
            selectedTravellerIds.insert(travellerId)
        }
    }
}

struct EditExpenseView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Bindable var expense: Expense
    var trip: Trip
    let travellers: [Traveller]
    
    @State private var title: String
    @State private var amount: String
    @State private var currency: String
    @State private var category: ExpenseCategory
    @State private var date: Date
    @State private var notes: String
    @State private var paidBy: String
    @State private var selectedTravellerIds: Set<String>
    
    init(expense: Expense, trip: Trip, travellers: [Traveller]) {
        self.expense = expense
        self.trip = trip
        self.travellers = travellers
        _title = State(initialValue: expense.title)
        _amount = State(initialValue: String(expense.amount))
        _currency = State(initialValue: expense.currency)
        _category = State(initialValue: expense.category)
        _date = State(initialValue: expense.date)
        _notes = State(initialValue: expense.notes)
        _paidBy = State(initialValue: expense.paidBy)
        _selectedTravellerIds = State(initialValue: Set(expense.sharedByMemberIds))
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Expense Details") {
                    TextField("Title", text: $title)
                    
                    HStack {
                        Text("$")
                        TextField("Amount", text: $amount)
                            .keyboardType(.decimalPad)
                    }
                    
                    Picker("Category", selection: $category) {
                        ForEach(ExpenseCategory.allCases, id: \.self) { category in
                            Label(category.rawValue, systemImage: category.icon)
                                .tag(category)
                        }
                    }
                    
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                }
                
                Section("Additional Information") {
                    Picker("Paid By", selection: $paidBy) {
                        Text("Not specified").tag("")
                        ForEach(travellers) { traveller in
                            Text(traveller.name).tag(traveller.name)
                        }
                    }
                    TextField("Currency", text: $currency)
                }
                
                Section {
                    if travellers.isEmpty {
                        Text("No travellers to share expense with")
                            .foregroundColor(.secondary)
                            .font(.subheadline)
                    } else {
                        ForEach(travellers) { traveller in
                            Button(action: {
                                toggleTravellerSelection(traveller)
                            }) {
                                HStack {
                                    Image(systemName: selectedTravellerIds.contains(traveller.id.uuidString) ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(selectedTravellerIds.contains(traveller.id.uuidString) ? .blue : .gray)
                                    
                                    VStack(alignment: .leading) {
                                        Text(traveller.name)
                                            .foregroundColor(.primary)
                                        Text(traveller.travellerType.rawValue)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                }
                            }
                        }
                        
                        if !travellers.isEmpty {
                            HStack {
                                Spacer()
                                Button(selectedTravellerIds.count == travellers.count ? "Deselect All" : "Select All") {
                                    if selectedTravellerIds.count == travellers.count {
                                        selectedTravellerIds.removeAll()
                                    } else {
                                        selectedTravellerIds = Set(travellers.map { $0.id.uuidString })
                                    }
                                }
                                .font(.subheadline)
                                Spacer()
                            }
                        }
                    }
                } header: {
                    Text("Shared By")
                } footer: {
                    Text("Select travellers who will share this expense")
                }
                
                Section("Notes") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 80)
                }
            }
            .navigationTitle("Edit Expense")
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
                    .disabled(title.isEmpty || amount.isEmpty || Double(amount) == nil)
                }
            }
        }
    }
    
    private func saveChanges() {
        guard let amountValue = Double(amount) else { return }
        
        expense.title = title
        expense.amount = amountValue
        expense.currency = currency
        expense.category = category
        expense.date = date
        expense.notes = notes
        expense.paidBy = paidBy
        expense.sharedByMemberIds = Array(selectedTravellerIds)
        
        try? modelContext.save()
        dismiss()
    }
    
    private func toggleTravellerSelection(_ traveller: Traveller) {
        let travellerId = traveller.id.uuidString
        if selectedTravellerIds.contains(travellerId) {
            selectedTravellerIds.remove(travellerId)
        } else {
            selectedTravellerIds.insert(travellerId)
        }
    }
}

#Preview {
    let trip = Trip(
        name: "Sample Trip",
        startDate: Date(),
        endDate: Date(),
        location: "Paris"
    )
    let travellers = [
        Traveller(name: "John", email: "john@example.com", phoneNumber: "", travellerType: .adult),
        Traveller(name: "Jane", email: "jane@example.com", phoneNumber: "", travellerType: .adult)
    ]
    return AddExpenseView(trip: trip, travellers: travellers)
        .modelContainer(for: [Trip.self, Traveller.self], inMemory: true)
}
