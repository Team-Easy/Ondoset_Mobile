//
//  OOTDMainView.swift
//  Ondoset
//
//  Created by KoSungmin on 4/7/24.
//

import SwiftUI

struct OOTDMainView: View {
    
    let views: [String] = ["추천", "날씨"]
    @State var selectedView: String = "추천"
    
    @State var openWeatherOptions: Bool = false
    @State var openTempRateOptions: Bool = false
    
    
    @State var isPostAvailable: Bool = false
    @State var showCantPostOOTDAlert: Bool = false
    @State var banPeriod: Int = 0
    
    let columns: [GridItem] = Array(repeating: .init(.fixed(screenWidth/2), spacing: 1), count: 2)

    @Namespace private var viewsNamespace
    
    @StateObject var ootdMainVM: OOTDMainViewModel = .init()
    @StateObject var ootdItemVM: OOTDItemViewModel = .init()
    @EnvironmentObject var wholeVM: WholeViewModel
    
    var body: some View {
        
        /// 각 탭의 메인 뷰마다 NavigationStack을 두는 것으로 설계합니다.
        NavigationStack {
            
            ZStack {
                
                VStack(spacing: 0) {
                    HStack {
                        ForEach(views, id: \.self) { view in
                            
                            ZStack {
                                
                                if selectedView == view {
                                    
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(.main)
                                        .matchedGeometryEffect(id: "view", in: viewsNamespace)
                                        .frame(width: 60, height: 2)
                                        .offset(y: 15)
                                }
                                
                                Text(view)
                                    .foregroundStyle(selectedView == view ? .main : .darkGray)
                                    .font(Font.pretendard(.medium, size: 17))
                                
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .onTapGesture {
                                withAnimation(.spring()) {
                                    selectedView = view
                                }
                            }
                        }
                        Spacer()
                    }
                    
                    TabView(selection: $selectedView) {
                        
                        ZStack {
                        
                            if ootdMainVM.recommendOotdList == [] {
                                
                                BlankDataIndicateComponent(explainText: "선택하신 날씨의 검색 결과가 없어요 \n 다른 날씨를 선택해보세요")
                                
                            } else {
                                
                                ScrollView(showsIndicators: false) {
                                    
                                    LazyVGrid(columns: columns, spacing: 1) {
                                        
                                        let ootdList = ootdMainVM.recommendOotdList
                                        
                                        ForEach(ootdList.indices, id: \.self) { index in
                                            
                                            let dateString = DateFormatter.string(epoch: ootdList[index].date)
                                            
                                            NavigationLink(destination: OOTDItemView(ootdId: ootdList[index].ootdId, ootdImageURL: ootdList[index].imageURL, dateString: dateString, lowestTemp: ootdList[index].lowestTemp, highestTemp: ootdList[index].highestTemp)) {
                                                
                                                OOTDComponent(date: dateString, minTemp: ootdList[index].lowestTemp, maxTemp: ootdList[index].highestTemp, ootdImageURL: ootdList[index].imageURL)
                                                    .frame(width: screenWidth / 2)
                                            }
                                            .onAppear {
                                                
                                                if index == ootdList.count - 1 {
                                                    
                                                    Task {
                                                        
                                                        await ootdMainVM.getRecommendOOTDList()
                                                        
                                                        print("=====추천뷰 요청=======")
                                                    }
                                                }
                                            }
                                        }
                                        
                                    }
                                } // ScrollView
                                .refreshable {
                                    Task {
                                        await ootdMainVM.getRecommendOOTDList()
                                    }
                                }
                            }
                            
                            VStack {
                                
                                Spacer()
                                
                                HStack {
                                    
                                    Spacer()
                                    
                                    NavigationLink(destination: AddOOTDView()) {
                                        
                                        Image("addMainButton")
                                            .padding(.trailing, 10)
                                            .padding(.bottom, 30)
                                    }
                                }
                            }
                        } // ZStack
                        .tag("추천")
                        //.padding(.bottom, screenHeight / 18)
                        
                        /// 추천 뷰
                        
                        /// 날씨 뷰
                        
                        ZStack(alignment: .top) {
                            
                            ScrollView(showsIndicators: false) {
                                
                                LazyVGrid(columns: columns, spacing: 1) {
                                    
                                    let ootdList = ootdMainVM.weatherOotdList
                                    
                                    ForEach(ootdList.indices, id: \.self) { index in

                                        let dateString = DateFormatter.string(epoch: ootdList[index].date)
                                        
                                        NavigationLink(destination: OOTDItemView(ootdId: ootdList[index].ootdId, ootdImageURL: ootdList[index].imageURL, dateString: dateString, lowestTemp: ootdList[index].lowestTemp, highestTemp: ootdList[index].highestTemp)) {
                                            OOTDComponent(date: dateString, minTemp: ootdList[index].lowestTemp, maxTemp: ootdList[index].highestTemp, ootdImageURL: ootdList[index].imageURL)
                                            .frame(width: screenWidth / 2)
                                        }
                                        .onAppear {
                                            
                                            if index == ootdList.count - 1 {
                                                Task {
                                                    await ootdMainVM.readWeatherOOTDList()
                                                }
                                            }
                                        }
                                    }
                                }
                                .padding(.top, 60)
                                
                            }
                            .onChange(of: ootdMainVM.selectedWeather) { weather in
                                
                                ootdMainVM.weatherOotdList = []
                                ootdMainVM.weatherLastPage = -1
                                
                                Task {
                                    await ootdMainVM.readWeatherOOTDList()
                                }
                            }
                            .onChange(of: ootdMainVM.selectedTempRate) { tempRate in
                                
                                ootdMainVM.weatherOotdList = []
                                ootdMainVM.weatherLastPage = -1
                                
                                Task {
                                    await ootdMainVM.readWeatherOOTDList()
                                }
                            }
                            .refreshable {
                                Task {
                                    await ootdMainVM.readWeatherOOTDList()
                                }
                            }
                            
                            VStack {
                                
                                HStack(alignment: .top, spacing: 12) {

                                    VStack {
                                        
                                        Button {
                                            
                                            withAnimation(.spring()) {
                                                openWeatherOptions.toggle()
                                            }
                                            
                                        } label: {
                                            ootdMainVM.selectedWeather.imageWhite
                                                .frame(width: 34, height: 34)
                                                .background(.main)
                                                .cornerRadius(50)
                                        }
                                        
                                        if openWeatherOptions {
                                            
                                            weatherListView
                                        }
                                    }
                                    
                                    VStack {
                                        
                                        Button {

                                            withAnimation(.spring()) {
                                                openTempRateOptions.toggle()
                                            }

                                        } label: {

                                            Text("\(ootdMainVM.selectedTempRate.section)")
                                                .foregroundStyle(.white)
                                                .padding(.horizontal, 10)
                                                .padding(.vertical, 5)
                                                .background(.main)
                                                .cornerRadius(50)
                                        }
                                        
                                        if openTempRateOptions {
                                            
                                            tempRateListView
                                        }
                                    }

                                    Spacer()
                                }
                                .padding(.leading, 30)
                                .padding(.vertical, 15)
                                
                                Spacer()
                                
                                HStack {
                                    
                                    Spacer()
                                    
                                    NavigationLink(destination: AddOOTDView()) {
                                        
                                        Image("addMainButton")
                                            .padding(.trailing, 10)
                                            .padding(.bottom, 30)
                                    }
                                    .disabled(!isPostAvailable)
                                    .onTapGesture {
                                        
                                        if !isPostAvailable {
                                            
                                            showCantPostOOTDAlert = true
                                        }
                                        
                                    }
                                }
                            }
                        }
                        .tag("날씨")
//                        .padding(.bottom, screenHeight / 18)
                        
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    .padding(.bottom, tabBarHeight)
                } // VStack
                .onAppear {
                    wholeVM.isTabBarHidden = false
                }
                .ignoresSafeArea(edges: .bottom)
                
                if showCantPostOOTDAlert {
                    
                    AlertComponent(showAlert: $showCantPostOOTDAlert, alertTitle: "OOTD를 작성할 수 없습니다.", alertContent: "사용자님의 활동에 문제가 감지되어 \n다음 기간동안 활동이 제한됩니다 \n기간: \(banPeriod)일", rightBtnTitle: "확인", rightBtnAction: {
                        showCantPostOOTDAlert = false
                    })
                    
                }
                
            } // ZStack
            .onAppear {
                
                Task {
                    
                    let result = await ootdMainVM.getBanPeriod()
                    
                    banPeriod = result
                    
                    if result <= 0 {
                        
                        isPostAvailable = true
                        
                    } else {
                        
                        isPostAvailable = false
                    }
                }
                wholeVM.isTabBarHidden = true
                
            }
        }
    }
    
    private var weatherListView: some View {
        
        VStack(spacing: 5) {
            
            ForEach(Weather.allCases, id: \.self) { weather in
                
                Button {
                    
                    ootdMainVM.selectedWeather = weather
                    
                    openWeatherOptions = false
                    
                } label: {
                    weather.imageWhite
                        .frame(width: 34, height: 34)
                        .background(.mainLight)
                        .cornerRadius(50)
                }
                
            }
        }
    }
    
    private var tempRateListView: some View {
        
        VStack(spacing: 5) {
         
            ForEach(TempRate.allCases, id: \.self) { tempRate in
                
                Button {
                    
                    ootdMainVM.selectedTempRate = tempRate
                    
                    openTempRateOptions = false
                    
                } label: {
                    
                    Text("\(tempRate.section)")
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(.mainLight)
                        .cornerRadius(50)
                }
                
            }
        }
    }
}

#Preview {
    OOTDMainView()
}
