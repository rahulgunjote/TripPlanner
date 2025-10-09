import SwiftUI
import MapKit

struct MapPreviewView: View {
    let latitude: Double
    let longitude: Double
    
    @State private var region: MKCoordinateRegion
    
    init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
        _region = State(initialValue: MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        ))
    }
    
    var body: some View {
        Map(position: .constant(.region(region))) {
            Marker("", coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
        }
        .disabled(true)
    }
}

