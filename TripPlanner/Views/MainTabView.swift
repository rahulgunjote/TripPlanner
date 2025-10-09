import SwiftUI
import SwiftData

struct MainTabView: View {
    var body: some View {
        TabView {
            TripListView()
                .tabItem {
                    Label("Trips", systemImage: "airplane")
                }
            
            TravellerListView()
                .tabItem {
                    Label("Travellers", systemImage: "person.2.fill")
                }
        }
    }
}

#Preview {
    MainTabView()
        .modelContainer(for: [Trip.self, Traveller.self], inMemory: true)
}

