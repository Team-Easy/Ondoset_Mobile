//
//  HomeMainView.swift
//  Ondoset
//
//  Created by KoSungmin on 4/7/24.
//

import SwiftUI

struct HomeMainView: View {
    
    @StateObject var homeMainVM: HomeMainViewModel = .init()
    
    var body: some View {
        
        /// 각 탭의 메인 뷰마다 NavigationStack을 두는 것으로 설계합니다.
        
        NavigationStack {
            VStack(spacing: 0) {
                WeatherView()
                    .environmentObject(homeMainVM)
                HomeBottomView()
                    .environmentObject(homeMainVM)
                Rectangle()
                    .frame(height: 44)
                    .foregroundStyle(.white)
            }
        }
        .sheet(isPresented: $homeMainVM.presentAIRecomm) {
            NavigationView { AICoordiRecommendView(AICoordiRecommendVM: .init(clothesData: homeMainVM.selectedClothTemplates ?? [.init(name: "")])) }
        }
    }
}


#Preview {
    HomeMainView()
}
