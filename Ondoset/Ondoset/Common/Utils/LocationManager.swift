//
//  LocationManager.swift
//  Ondoset
//
//  Created by KoSungmin on 5/10/24.
//

import Foundation
import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    public let locationManager = CLLocationManager()
    @Published var currentLocation: CLLocationCoordinate2D?
    @Published var authorizationStatus: CLAuthorizationStatus?
    @Published var showSettingAlert = false

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
    }

    func requestLocation() {
        locationManager.requestLocation() // 단일 위치 요청
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            currentLocation = location.coordinate
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .notDetermined:
            /// 아직 정해지지 않음
            print("notDetermined")
        case .restricted:
            print("restricted")
        case .denied:
            /// 허용 안함
            /// 사용자가 한 번 거부하면 반복적으로 물어볼 수 없습니다.
            print("denied")
            UserDefaults.standard.set(LocationAuthorizationType.denied.rawValue, forKey: "locationAuthorization")
            showSettingAlert = true
        case .authorizedAlways:
            print("authorzedAlways")
        case .authorizedWhenInUse:
            /// 한 번 허용 & 앱을 사용하는 동안 허용
            print("authorizedWhenInUse")
            UserDefaults.standard.set(LocationAuthorizationType.authorizedWhenInUse.rawValue, forKey: "locationAuthorization")
        @unknown default:
            print("default")
        }
    }
}

enum LocationAuthorizationType: String {
    /// 아직 정해지지 않음
    case notDetermined
    /// 허용 안 함
    case denied
    /// 앱을 사용하는 동안 허용
    case authorizedWhenInUse
    /// 한 번 허용
    case authorizedOnce
}
