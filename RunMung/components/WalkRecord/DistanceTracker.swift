//
//  LocationManger.swift
//  RunMung
//
//  Created by 고래돌 on 9/17/25.
//

import CoreLocation
import Combine

class DistanceTracker: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var totalDistance: Double = 0.0
    
    private var locationManager = CLLocationManager()
    private var lastLocation: CLLocation?
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last else { return }
        
        if let last = lastLocation {
            let distance = newLocation.distance(from: last) // 미터 단위
            totalDistance += distance / 1000.0 // km로 변환
        }
        
        lastLocation = newLocation
    }
}

