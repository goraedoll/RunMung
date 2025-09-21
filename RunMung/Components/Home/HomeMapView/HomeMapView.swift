//
//  HomeMapView.swift
//  RunMung
//
//  Created by 고래돌 on 9/16/25.
//
import SwiftUI
import MapKit
import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var region = MKCoordinateRegion(
        // 기본 위치 서울 시청으로 해놓음
        center: CLLocationCoordinate2D(latitude: 37.5665, longitude: 126.9780),
        
        // 이부분을 수정해야 축적 비율이 설정됌
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    private let manager = CLLocationManager()

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        manager.distanceFilter = 50
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.startUpdatingLocation()
        case .denied, .restricted:
            print("위치 권한 없음")
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        @unknown default: break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        DispatchQueue.main.async {
            self.region.center = location.coordinate
        }
    }
}

struct HomeMapView: View {
    @StateObject private var locationManager = LocationManager()

    // iOS 17 스타일: 카메라 위치 바인딩
    @State private var camera: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 37.5665, longitude: 126.9780),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
    )

    var body: some View {
        Map(position: $camera, interactionModes: .all) {
            // ✅ 파란 점(사용자 위치)은 이렇게
            UserAnnotation()

            // ✅ 커스텀 마커가 필요하면 Marker/Annotation 사용
//            Marker("내 위치", coordinate: locationManager.region.center)
//                .tint(.red)
        }
        // region이 바뀔 때 카메라도 따라가게
        .onReceive(locationManager.$region) { newRegion in
            camera = .region(newRegion)
        }
        // 바깥을 흰색으로 덮는 원형 그라데이션
        .overlay(
            RadialGradient(
                gradient: Gradient(colors: [.clear, .white.opacity(0.9)]),
                center: .center,
                startRadius: 50,
                endRadius: 220
            )
        )
        .ignoresSafeArea()
    }
}


#Preview ("Home") {
    ContentView()
}

