# Trip Planner iOS App

A comprehensive trip planning application built with SwiftUI and Swift Data for iOS. Plan your trips, manage itineraries, track expenses, and organize trip members all in one place.

## Features

### 🗺️ Trip Management
- Create and manage multiple trips
- Add trip details including name, dates, location, and optional images
- View trip location on an interactive map
- Add notes and descriptions for each trip

### 👥 Trip Members
- Add multiple members to each trip
- Store contact information (name, email, phone)
- View all trip participants at a glance

### 📋 Itinerary Planning
- Create detailed itinerary items for each day
- Set start and end times for activities
- Mark activities as completed
- Add locations with map integration
- Group itinerary items by date
- Add descriptions and notes for each activity

### 💰 Expense Tracking
- Track all trip expenses
- Categorize expenses (Accommodation, Transportation, Food & Dining, Activities, Shopping, Other)
- Assign expenses to specific trip members
- View total expenses per trip
- Group expenses by category
- Add notes for each expense

### 📱 User Interface
- **Screen 1 - Trip List**: Browse all your trips with name, date, location, and image preview. Shows an empty state message when no trips exist. Features a floating action button to create new trips.
- **Screen 2 - Create/Edit Trip**: Add trip details, select location on map, add trip members, and set trip image.
- **Screen 3 - Trip Details**: View comprehensive trip information, manage expenses, access itinerary, and see trip members.
- **Itinerary Screen**: Dedicated screen for managing daily activities and plans.

### 💾 Data Persistence
- All data is stored locally using Swift Data
- Automatic synchronization across the app
- Efficient relationship management between trips, members, itinerary items, and expenses

## Architecture

### Models
The app uses Swift Data for data persistence with the following model structure:

- **Trip**: Main entity containing trip information, relationships to members, itinerary items, and expenses
- **TripMember**: Represents trip participants with contact information
- **ItineraryItem**: Individual activities and plans for the trip
- **Expense**: Financial records with categories and amounts

### ViewModels
- **TripViewModel**: Handles all business logic for trip management, member operations, itinerary management, and expense tracking

### Views
- **TripListView**: Main screen showing all trips
- **CreateTripView**: Form for creating new trips
- **TripDetailView**: Detailed view of a single trip
- **ItineraryView**: Manage trip itinerary items
- **AddExpenseView / EditExpenseView**: Expense management screens
- **LocationPickerView**: Interactive map for selecting locations
- **AddMemberView**: Form for adding trip members

## Testing

The app includes comprehensive unit tests using Swift Testing framework:

### TripViewModelTests
Tests for all ViewModel business logic including:
- Trip CRUD operations
- Member management
- Itinerary operations
- Expense tracking
- Utility methods (total calculations, grouping by category/date)

### TripModelTests
Tests for model functionality including:
- Model initialization
- Computed properties
- Date formatting
- Expense calculations
- Category management

## Requirements

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+

## Installation

1. Clone the repository
2. Open `TripPlanner.xcodeproj` in Xcode
3. Build and run on your iOS device or simulator

## Usage

### Creating a Trip
1. Tap the floating "+" button on the main screen
2. Fill in trip details (name, dates, location)
3. Optionally add an image from your photo library
4. Select trip location on the map
5. Add trip members
6. Save the trip

### Managing Itinerary
1. Open a trip from the trip list
2. Tap on the "Itinerary" section
3. Add activities with dates, times, and locations
4. Mark activities as completed during your trip
5. Edit or delete activities as needed

### Tracking Expenses
1. Open a trip from the trip list
2. Scroll to the "Expenses" section
3. Tap "Add" to create a new expense
4. Select category, amount, and who paid
5. View total expenses and breakdown by category

## Project Structure

```
TripPlanner/
├── Models/
│   ├── Trip.swift
│   ├── TripMember.swift
│   ├── ItineraryItem.swift
│   └── Expense.swift
├── ViewModels/
│   └── TripViewModel.swift
├── Views/
│   ├── TripListView.swift
│   ├── CreateTripView.swift
│   ├── TripDetailView.swift
│   ├── ItineraryView.swift
│   ├── AddItineraryItemView.swift
│   ├── AddExpenseView.swift
│   ├── AddMemberView.swift
│   └── LocationPickerView.swift
└── TripPlannerApp.swift

TripPlannerTests/
├── TripViewModelTests.swift
└── TripModelTests.swift
```

## Technologies Used

- **SwiftUI**: Modern declarative UI framework
- **Swift Data**: Apple's latest persistence framework
- **MapKit**: Location selection and map display
- **Swift Testing**: Modern testing framework
- **Contacts & ContactsUI**: Import travellers from device contacts

## Testing

The project includes comprehensive test coverage:

### Unit Tests
- **TripViewModelTests**: Tests for trip management logic
- **TravellerViewModelTests**: Tests for traveller CRUD operations
- **ItineraryViewModelTests**: Tests for itinerary functionality
- **ExpenseViewModelTests**: Tests for expense calculations and splitting
- **TripModelTests**: Tests for data models

### UI Tests
- **TripPlannerUITests**: Core functionality and navigation tests
- **TripFlowUITests**: Complete trip lifecycle testing
- **TravellerFlowUITests**: Traveller management and contact import
- **ItineraryAndExpenseUITests**: Itinerary and expense feature testing

**Total Coverage**: 50+ UI tests covering all major user flows

For detailed information about running and maintaining tests, see [UI_TESTS_GUIDE.md](UI_TESTS_GUIDE.md).

### Running Tests

```bash
# Run all tests
xcodebuild test -project TripPlanner.xcodeproj -scheme TripPlanner -destination 'platform=iOS Simulator,name=iPhone 17'

# Or in Xcode: ⌘U
```

## Future Enhancements

- Cloud sync using CloudKit
- Share trips with other users
- Export trip summary as PDF
- Weather integration for trip locations
- Currency conversion for international trips
- Photo gallery for trip memories
- Offline maps support

## License

This project is available for personal and educational use.

## Author

Created with SwiftUI and Swift Data for iOS trip planning.

---

**Happy Trip Planning! ✈️🌍**

