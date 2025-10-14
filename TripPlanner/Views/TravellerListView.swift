import SwiftUI
import SwiftData
import Contacts
import ContactsUI

struct TravellerListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Traveller.name) private var travellers: [Traveller]
    @State private var showingAddTravellerOptions = false
    @State private var showingManualAdd = false
    @State private var showingContactPicker = false
    @State private var selectedTraveller: Traveller?
    @State private var searchText = ""
    
    private var travellerViewModel: TravellerViewModel {
        TravellerViewModel(modelContext: modelContext)
    }
    
    var filteredTravellers: [Traveller] {
        if searchText.isEmpty {
            return travellers
        }
        return travellerViewModel.searchTravellersGlobally(query: searchText)
    }
    
    var adults: [Traveller] {
        filteredTravellers.filter { $0.travellerType == .adult }
    }
    
    var children: [Traveller] {
        filteredTravellers.filter { $0.travellerType == .child }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                if travellers.isEmpty {
                    EmptyTravellerListView(onAddTraveller: {
                        showingAddTravellerOptions = true
                    })
                } else {
                    List {
                        if !adults.isEmpty {
                            Section("Adults (\(adults.count))") {
                                ForEach(adults) { traveller in
                                    TravellerRow(traveller: traveller)
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            selectedTraveller = traveller
                                        }
                                }
                                .onDelete { indexSet in
                                    deleteAdults(at: indexSet)
                                }
                            }
                        }
                        
                        if !children.isEmpty {
                            Section("Children (\(children.count))") {
                                ForEach(children) { traveller in
                                    TravellerRow(traveller: traveller)
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            selectedTraveller = traveller
                                        }
                                }
                                .onDelete { indexSet in
                                    deleteChildren(at: indexSet)
                                }
                            }
                        }
                    }
                    .searchable(text: $searchText, prompt: "Search travellers")
                }
                
                // Floating Add Button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        FloatingAddButton {
                            showingAddTravellerOptions = true
                        }
                        .padding()
                        .confirmationDialog("Add Traveller", isPresented: $showingAddTravellerOptions) {
                            VStack {
                                Button("Import from Contacts") {
                                    showingContactPicker = true
                                }
                                Button("Add Manually") {
                                    showingManualAdd = true
                                }
                            }
                        } message: {
                            Text("Choose how you'd like to add a traveller")
                        }
                    }
                }
                
            }
            .navigationTitle("Travellers")
            .sheet(isPresented: $showingManualAdd) {
                AddTravellerView()
                    .presentationDetents([.medium, .large])
            }
            .sheet(isPresented: $showingContactPicker) {
                ContactPickerView { contact in
                    createTravellerFromContact(contact)
                }
            }
            .sheet(item: $selectedTraveller) { traveller in
                EditTravellerView(traveller: traveller)
                    .presentationDetents([.medium, .large])
            }
//            .actionSheet(isPresented: $showingAddTravellerOptions) {
//                ActionSheet(
//                    title: Text("Add Traveller"),
//                    message: Text("Choose how you'd like to add a traveller"),
//                    buttons: [
//                        .default(Text("Import from Contacts")) {
//                            showingContactPicker = true
//                        },
//                        .default(Text("Add Manually")) {
//                            showingManualAdd = true
//                        },
//                        .cancel()
//                    ]
//                )
//            }
        }
    }
    
    private func deleteAdults(at offsets: IndexSet) {
        for index in offsets {
            let traveller = adults[index]
            travellerViewModel.deleteTraveller(traveller)
        }
    }
    
    private func deleteChildren(at offsets: IndexSet) {
        for index in offsets {
            let traveller = children[index]
            travellerViewModel.deleteTraveller(traveller)
        }
    }
    
    private func createTravellerFromContact(_ contact: CNContact) {
        let name = "\(contact.givenName) \(contact.familyName)".trimmingCharacters(in: .whitespaces)
        let email = contact.emailAddresses.first?.value as String? ?? ""
        let phoneNumber = contact.phoneNumbers.first?.value.stringValue ?? ""
        
        _ = travellerViewModel.createTraveller(
            name: name.isEmpty ? "Contact" : name,
            email: email,
            phoneNumber: phoneNumber,
            travellerType: .adult
        )
    }
}

struct TravellerRow: View {
    let traveller: Traveller
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: traveller.travellerType == .adult ? "person.circle.fill" : "figure.and.child.holdinghands")
                .font(.title2)
                .foregroundColor(.blue)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(traveller.name)
                        .font(.body)
                        .fontWeight(.medium)
                    
                    Text("(\(traveller.travellerType.rawValue))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
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

struct EmptyTravellerListView: View {
    let onAddTraveller: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.2.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(.gray)
            
            Text("No Travellers Yet")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Add travellers to reuse them across multiple trips")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button(action: onAddTraveller) {
                Label("Add First Traveller", systemImage: "person.badge.plus")
                    .font(.headline)
            }
            .buttonStyle(.borderedProminent)
        }
    }
}

struct FloatingAddButton: View {
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

struct ContactPickerView: UIViewControllerRepresentable {
    let onContactSelected: (CNContact) -> Void
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> CNContactPickerViewController {
        let picker = CNContactPickerViewController()
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: CNContactPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, CNContactPickerDelegate {
        let parent: ContactPickerView
        
        init(_ parent: ContactPickerView) {
            self.parent = parent
        }
        
        func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
            parent.onContactSelected(contact)
            parent.dismiss()
        }
        
        func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
            parent.dismiss()
        }
    }
}

struct AddTravellerView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var email = ""
    @State private var phoneNumber = ""
    @State private var travellerType: TravellerType = .adult
    @State private var showingValidationError = false
    @State private var validationErrorMessage = ""
    
    private var travellerViewModel: TravellerViewModel {
        TravellerViewModel(modelContext: modelContext)
    }
    
    private var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        (email.isEmpty || travellerViewModel.validateEmail(email)) &&
        (phoneNumber.isEmpty || travellerViewModel.validatePhoneNumber(phoneNumber))
    }
    
    private var emailValidationMessage: String? {
        if !email.isEmpty && !travellerViewModel.validateEmail(email) {
            return "Invalid email format"
        }
        return nil
    }
    
    private var phoneValidationMessage: String? {
        if !phoneNumber.isEmpty && !travellerViewModel.validatePhoneNumber(phoneNumber) {
            return "Phone number must be at least 10 digits"
        }
        return nil
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Traveller Information") {
                    TextField("Name", text: $name)
                    
                    Picker("Type", selection: $travellerType) {
                        Text("Adult").tag(TravellerType.adult)
                        Text("Child").tag(TravellerType.child)
                    }
                    .pickerStyle(.segmented)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        TextField("Email (optional)", text: $email)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                        
                        if let message = emailValidationMessage {
                            Text(message)
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        TextField("Phone Number (optional)", text: $phoneNumber)
                            .keyboardType(.phonePad)
                        
                        if let message = phoneValidationMessage {
                            Text(message)
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            .navigationTitle("Add Traveller")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        addTraveller()
                    }
                    .disabled(!isFormValid)
                }
            }
            .alert("Validation Error", isPresented: $showingValidationError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(validationErrorMessage)
            }
        }
    }
    
    private func addTraveller() {
        // Final validation before saving
        guard travellerViewModel.validateTravellerName(name) else {
            validationErrorMessage = "Please enter a valid name"
            showingValidationError = true
            return
        }
        
        guard email.isEmpty || travellerViewModel.validateEmail(email) else {
            validationErrorMessage = "Please enter a valid email address"
            showingValidationError = true
            return
        }
        
        guard phoneNumber.isEmpty || travellerViewModel.validatePhoneNumber(phoneNumber) else {
            validationErrorMessage = "Please enter a valid phone number (at least 10 digits)"
            showingValidationError = true
            return
        }
        
        _ = travellerViewModel.createTraveller(
            name: name,
            email: email,
            phoneNumber: phoneNumber,
            travellerType: travellerType
        )
        dismiss()
    }
}

struct EditTravellerView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Bindable var traveller: Traveller
    
    @State private var name: String
    @State private var email: String
    @State private var phoneNumber: String
    @State private var travellerType: TravellerType
    @State private var showingValidationError = false
    @State private var validationErrorMessage = ""
    
    private var travellerViewModel: TravellerViewModel {
        TravellerViewModel(modelContext: modelContext)
    }
    
    init(traveller: Traveller) {
        self.traveller = traveller
        _name = State(initialValue: traveller.name)
        _email = State(initialValue: traveller.email)
        _phoneNumber = State(initialValue: traveller.phoneNumber)
        _travellerType = State(initialValue: traveller.travellerType)
    }
    
    private var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        (email.isEmpty || travellerViewModel.validateEmail(email)) &&
        (phoneNumber.isEmpty || travellerViewModel.validatePhoneNumber(phoneNumber))
    }
    
    private var emailValidationMessage: String? {
        if !email.isEmpty && !travellerViewModel.validateEmail(email) {
            return "Invalid email format"
        }
        return nil
    }
    
    private var phoneValidationMessage: String? {
        if !phoneNumber.isEmpty && !travellerViewModel.validatePhoneNumber(phoneNumber) {
            return "Phone number must be at least 10 digits"
        }
        return nil
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Traveller Information") {
                    TextField("Name", text: $name)
                    
                    Picker("Type", selection: $travellerType) {
                        Text("Adult").tag(TravellerType.adult)
                        Text("Child").tag(TravellerType.child)
                    }
                    .pickerStyle(.segmented)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        TextField("Email (optional)", text: $email)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                        
                        if let message = emailValidationMessage {
                            Text(message)
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        TextField("Phone Number (optional)", text: $phoneNumber)
                            .keyboardType(.phonePad)
                        
                        if let message = phoneValidationMessage {
                            Text(message)
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                }
                
                Section {
                    Button(role: .destructive) {
                        deleteTraveller()
                    } label: {
                        HStack {
                            Spacer()
                            Label("Delete Traveller", systemImage: "trash")
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Edit Traveller")
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
                    .disabled(!isFormValid)
                }
            }
            .alert("Validation Error", isPresented: $showingValidationError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(validationErrorMessage)
            }
        }
    }
    
    private func saveChanges() {
        // Final validation before saving
        guard travellerViewModel.validateTravellerName(name) else {
            validationErrorMessage = "Please enter a valid name"
            showingValidationError = true
            return
        }
        
        guard email.isEmpty || travellerViewModel.validateEmail(email) else {
            validationErrorMessage = "Please enter a valid email address"
            showingValidationError = true
            return
        }
        
        guard phoneNumber.isEmpty || travellerViewModel.validatePhoneNumber(phoneNumber) else {
            validationErrorMessage = "Please enter a valid phone number (at least 10 digits)"
            showingValidationError = true
            return
        }
        
        travellerViewModel.updateTraveller(
            traveller: traveller,
            name: name,
            email: email,
            phoneNumber: phoneNumber,
            travellerType: travellerType
        )
        dismiss()
    }
    
    private func deleteTraveller() {
        travellerViewModel.deleteTraveller(traveller)
        dismiss()
    }
}

#Preview {
    TravellerListView()
        .modelContainer(for: Traveller.self, inMemory: true)
}
