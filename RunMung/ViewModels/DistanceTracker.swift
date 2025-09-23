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
    @Published var locations: [CLLocation] = []
    
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
        
        locationManager.activityType = .fitness // 산책 옵션으로 선택
    }
    
    // 세션 시작
    func start() {
        lastLocation = nil
        isTracking = true
        locations.removeAll() // 세션 시작 시 초기화
        totalDistance = 0.0
        locationManager.startUpdatingLocation()
    }
    
    // 세션 일시정지 / 정지
    func stop() {
        isTracking = false
        locationManager.stopUpdatingLocation()
    }
    
    // 세션 리셋
    func reset() {
        stop()
        totalDistance = 0.0
        lastLocation = nil
        locations.removeAll()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard isTracking else { return }
        guard let newLocation = locations.last else { return }
        
        if let last = lastLocation {
            let distance = newLocation.distance(from: last) // 미터 단위
            if distance > 1 {
                totalDistance += distance / 1000.0 // km 단위 변환
            }
        }
        
        self.locations.append(newLocation) // 위치 기록 추가
        lastLocation = newLocation
    }
}

