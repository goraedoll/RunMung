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
    private var isTracking: Bool = false // 기록 상태
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        
        // 백그라운드에서도 위치 추적 가능하게
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        
        // 산책 개선
        locationManager.activityType = .fitness
    }
    
    func start() {
        lastLocation = nil
        isTracking = true
        locationManager.startUpdatingLocation()
    }
    
    func stop() {
        isTracking = false
        locationManager.stopUpdatingLocation()
    }
    
    func reset() {
        stop()
        totalDistance = 0.0
        lastLocation = nil
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard isTracking else { return }
        guard let newLocation = locations.last else { return }
        
        if let last = lastLocation {
            // 미터 단위
            let distance = newLocation.distance(from: last)
            
            // 1미터 미만의 작은 변화는 무시
            if distance > 1 {
                totalDistance += distance / 1000.0 // km 단위 변환
            }
        }
        
        lastLocation = newLocation
    }
}

