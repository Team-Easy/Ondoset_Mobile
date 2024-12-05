//
//  SplashView.swift
//  Ondoset
//
//  Created by KoSungmin on 4/7/24.
//

import SwiftUI

struct SplashView: View {
    @State var isActive: Bool = false
    @AppStorage("isLogin") var isLogin: Bool = false
    @AppStorage("isFirst") var isFirst: Bool = true
    @StateObject var locationManager: LocationManager = LocationManager()
    @AppStorage("locationAuthorization") var locationAuth: LocationAuthorizationType = .notDetermined
    
    init() {
        UserDefaults.standard.register(defaults: ["locationAuthorization": LocationAuthorizationType.notDetermined.rawValue])
    }
    
    var body: some View {
        ZStack {
            if !isLogin && isActive {
                SignInView()
            } else if isLogin && isActive {
                OndosetHome()
            } else {
                ZStack {
                    Color(.main)
                    VStack {
                        Image("whiteAppIcon")
                        Text("ondoset")
                            .font(Font.pretendard(.bold, size: 50))
                            .foregroundStyle(.white)
                    }
                }
            }
        }
        .onAppear {
            if locationAuth == .notDetermined {
                locationManager.locationManager.requestWhenInUseAuthorization()
            } else if locationAuth == .authorizedWhenInUse {
                isActive = true
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            let status = locationManager.locationManager.authorizationStatus
            if status == .authorizedWhenInUse {
                locationAuth = .authorizedWhenInUse
                isActive = true
            } else if status == .denied {
                locationAuth = .denied
                locationManager.showSettingAlert = true
            }
        }
        .alert(isPresented: $locationManager.showSettingAlert) {
            Alert(
                title: Text("위치 권한 필요"),
                message: Text("위치 권한이 거부되었습니다. 위치 정보를 사용하려면 설정에서 권한을 허용해주세요."),
                primaryButton: .default(Text("설정으로 이동"), action: {
                    if let appSetting = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(appSetting)
                    }
                }),
                secondaryButton: .cancel(Text("취소"), action: {
                    if locationAuth == .denied {
                        locationManager.locationManager.requestWhenInUseAuthorization()
                    }
                })
            )
        }
        .ignoresSafeArea()
    }
}

//#Preview {
//    SplashView(locationManager: LocationManager())
//}
