import Foundation
import CoreLocation

class LocationManager: NSObject, CLLocationManagerDelegate, ObservableObject {
    private let locationManager = CLLocationManager()
    
    @Published var location: CLLocationCoordinate2D?
    
    override init() {
        super.init()
        
        locationManager.delegate = self
    }
    
    func requestLocation() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first?.coordinate else { return }
        self.location = location
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error getting location: \(error.localizedDescription)")
    }
    
    func geocodeCity(city: String, completion: @escaping (CLLocationCoordinate2D?) -> Void) {
        let geocoder = CLGeocoder()
        
        geocoder.geocodeAddressString(city) { (placemarks, error) in
            guard error == nil else {
                print("Geocoding error: \(error!.localizedDescription)")
                completion(nil)
                return
            }
            
            if let placemark = placemarks?.first,
               let location = placemark.location {
                completion(location.coordinate)
            } else {
                completion(nil)
            }
        }
    }
}
