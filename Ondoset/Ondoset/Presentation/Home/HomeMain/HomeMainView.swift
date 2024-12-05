//
//  HomeMainView.swift
//  Ondoset
//
//  Created by KoSungmin on 4/7/24.
//

import SwiftUI

struct HomeMainView: View {
    
    // 지역 정보 검색 화면 sheet
    @State var isLocationViewSheetPresented: Bool = false
    
    // 지역 정보 검색 텍스트
    @State var locationSearchText: String = ""
    
    @StateObject var homeMainVM: HomeMainViewModel = .init()
    
    @StateObject var locationManager = LocationManager()
    
    var body: some View {
        
        /// 각 탭의 메인 뷰마다 NavigationStack을 두는 것으로 설계합니다.
        
        NavigationStack {
            ZStack {
                VStack(spacing: 0) {
                    WeatherView(isLocationViewSheetPresented: $isLocationViewSheetPresented)
                        .environmentObject(homeMainVM)
                        .environmentObject(locationManager)
                    HomeBottomView()
                        .environmentObject(homeMainVM)
                    Rectangle()
                        .frame(height: 44)
                        .foregroundStyle(.white)
                }
                .padding(.vertical)
                
                if homeMainVM.isHomeInfoFetching {
                    Color.white.opacity(0.3)
                    
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .mainLight))
                        .scaleEffect(2.0, anchor: .center)
                }
            }
        }
        .onAppear(perform: {
            homeMainVM.homeViewDate = .now
            
//            locationManager.requestLocation()
            
            if let location = locationManager.currentLocation {
                
                homeMainVM.homeViewLocate = .init(latitude: location.latitude, longitude: location.longitude)
            }
            
        })
        .sheet(isPresented: $homeMainVM.presentAIRecomm) {
                NavigationView { AICoordiRecommendView(viewType: homeMainVM.presentSheetViewType, AICoordiRecommendVM: .init(clothesData: homeMainVM.selectedClothTemplates ?? [.init(name: "")], presentingDate: homeMainVM.homeViewPresentingDate)) }
            }

        .sheet(isPresented: $isLocationViewSheetPresented) {
            
            LocationView(locationSearchText: $locationSearchText, lat: $homeMainVM.homeViewLocate.latitude, lon: $homeMainVM.homeViewLocate.longitude, isLocationViewSheetPresented: $isLocationViewSheetPresented)
                .presentationDetents([.height(screenHeight / 3)])
        }
    }
}


#Preview {
    HomeMainView()
}
