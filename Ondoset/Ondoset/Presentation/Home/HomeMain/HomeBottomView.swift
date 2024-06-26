//
//  HomeBottomView.swift
//  Ondoset
//
//  Created by 박민서 on 5/2/24.
//

import SwiftUI

enum HomeBottomViewType: CaseIterable {
    case TodaysSetUpView
    case SetUpHistoryView
    case AIRecommendView
    case OthersOOTDView
    
    var title: String {
        switch self {
            
        case .TodaysSetUpView:
            return "오늘은 이렇게 입기로 했어요"
        case .SetUpHistoryView:
            return "전엔 이렇게 입었어요"
        case .AIRecommendView:
            return "AI가 추천하는 오늘의 코디"
        case .OthersOOTDView:
            return "다른 사람들은 이렇게 입었어요"
        }
    }
}

struct HomeBottomView: View {
    // State
    @State var currentPage: Int = 0
    
    var body: some View {
        TabView(selection: $currentPage) {
            ForEach(0..<4) { index in
                VStack(spacing: 0) {
                    HomeBottomHeaderView(viewType: HomeBottomViewType.allCases[index])
                    switch index {
                    case 0:
                        TodaysSetUpView()
                    case 1:
                        SetUpHistoryView()
                    case 2:
                        AIRecommendView()
                    case 3:
                        OthersOOTDView()
                    default:
                        Spacer()
                    }
                    HomeBottomFooterView(currentPage: $currentPage)
                }
                .background(Color.ondosetBackground)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
    }
}

struct HomeBottomHeaderView: View {
    @EnvironmentObject var wholeVM: WholeViewModel
    @EnvironmentObject var homeMainVM: HomeMainViewModel
    // properties
    var viewType: HomeBottomViewType
    
    var body: some View {
        VStack {
            HStack {
                Text(viewType.title)
                    .font(.pretendard(.semibold, size: 17))
                Spacer()
                if viewType == .OthersOOTDView {
                    Button(action: {
                        wholeVM.selectedTab = .ootd
                    }, label: {
                        HStack(spacing: 0) {
                            Text("OOTD")
                                .font(.pretendard(.semibold, size: 13))
                            Image(systemName: "chevron.forward")
                        }
                        .foregroundStyle(.main)
                    })
                }
            }
            Divider()
                .frame(height: 2)
                .overlay(Color.white)
        }
        .padding()
    }
}

// MARK: TodaysSetUpView
struct TodaysSetUpView: View {
    @EnvironmentObject var homeMainVM: HomeMainViewModel
    
    var body: some View {
        VStack {
            // Plan 내용 존재할 때
            if let coordiPlan = homeMainVM.coordiPlan {
                // 옷 표시 스크롤뷰
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHGrid(rows: [
                        GridItem(.flexible(), spacing: 10, alignment: .leading),
                        GridItem(.flexible(), spacing: 10, alignment: .leading),
                        GridItem(.flexible(), spacing: 10, alignment: .leading)
                    ], content: {
                        ForEach(homeMainVM.coordiPlan ?? [], id: \.clothesId) { cloth in
                            ClothTagComponent(isSelected: .constant(true), tagTitle: cloth.name, category: cloth.category)
                        }
                    })
                    .frame(height: 100)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
                Spacer()
                // 추위미터기 버튼
                ButtonComponent(isBtnAvailable: .constant(homeMainVM.coordiPlan != nil), width: 340, btnText: "추위 미터기 확인하기", radius: 15, action: {
                    homeMainVM.selectPlan(homeMainVM.coordiPlan ?? [])
                })
                    .padding()
            }
            // Plan 내용 없을 때
            else {
                Spacer()
                BlankDataIndicateComponent(explainText: "오늘 입기로 한 코디가 없어요\n코디를 등록해주세요")
                Spacer()
            }
            
        }
    }
}
// MARK: SetUpHistoryView
struct SetUpHistoryView: View {
    
    @EnvironmentObject var wholeVM: WholeViewModel
    @EnvironmentObject var homeMainVM: HomeMainViewModel

    var body: some View {
        // 전에 입은 코디 기록 존재할 때
        if !homeMainVM.similRecord.isEmpty {
            ScrollView(.vertical) {
                ForEach(homeMainVM.similRecord.indices, id: \.self) { index in
                    ScrollView(.horizontal) {
                        
                        LazyHGrid(rows: [
                            GridItem(.flexible(),spacing: 10, alignment: .leading),
                            GridItem(.flexible(), spacing: 10, alignment: .leading)
                        ]) {
                            Text(DateFormatter.dateOnly.string(from: homeMainVM.getDate(from: homeMainVM.similRecord[index].date)!))
                                .font(Font.pretendard(.semibold, size: 13))
                                .padding(.horizontal, 20)
                                .padding(.vertical, 4)
                                .background(index % 2 == 0 ? .white : .ondosetBackground)
                                .foregroundColor(.black)
                                .cornerRadius(30)
                            ForEach(homeMainVM.similRecord[index].clothesList, id: \.clothesId) { cloth in
                                ClothTagComponent(isSelected: .constant(true), tagTitle: cloth.name, category: cloth.category)
                            }
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal, 20)
                        .onTapGesture {
                            
                            wholeVM.goToCoordiThroughHome = true
                           
                            let date = Date(timeIntervalSince1970: TimeInterval(homeMainVM.similRecord[index].date))
                            
                            let calendar = Calendar.current
                            let components = calendar.dateComponents([.year, .month, .day], from: date)
                            
                            wholeVM.selectedCoordiYear = components.year ?? 0
                            wholeVM.selectedCoordiMonth = components.month ?? 0
                            wholeVM.selectedCoordiDay = components.day ?? 0
                            
                            withAnimation(.easeInOut(duration: 0.5)) {

                                wholeVM.selectedTab = .record
                            }
                        }
                        
                    }
                    .background(index % 2 == 0 ? .ondosetBackground : .white )
                }
            }
        }
        // 전에 입은 코디 기록 존재하지 않을 때
        else {
            Spacer()
            BlankDataIndicateComponent(explainText: "아직 충분한 데이터가 쌓이지 않았어요\n코디를 더 등록해주세요")
            Spacer()
        }
        
    }
}
// MARK: AIRecommendView
struct AIRecommendView: View {
    @EnvironmentObject var homeMainVM: HomeMainViewModel
    
    var body: some View {
        // AI 추천 코디 존재할 때
        if !homeMainVM.recommendAI.isEmpty {
            ScrollView(.vertical) {
                ForEach(homeMainVM.recommendAI.indices, id: \.self) { index in
                    ScrollView(.horizontal) {
                        LazyHGrid(rows: [
                            GridItem(.flexible(),spacing: 10, alignment: .leading),
                            GridItem(.flexible(), spacing: 10, alignment: .leading)
                        ]) {
                            Text("#\(index+1)")
                                .font(Font.pretendard(.semibold, size: 13))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(index % 2 == 0 ? .ondosetBackground : .white )
                                .foregroundColor(.black)
                                .cornerRadius(30)
                            ForEach(homeMainVM.recommendAI[index].indices, id: \.self) { idx in
                                ClothTagComponent(isSelected: .constant(true), tagTitle: homeMainVM.recommendAI[index][idx].fullTag, category: homeMainVM.recommendAI[index][idx].category)
                            }
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal, 20)
                        
                    }
                    .background(index % 2 == 0 ? .white : .ondosetBackground)
                    .onTapGesture {
                        homeMainVM.selectRecommendation(homeMainVM.recommendAI[index])
                    }
                }
            }
        } 
        // AI 추천 코디 존재하지 않을 때
        else {
            Spacer()
            BlankDataIndicateComponent(explainText: "아직 충분한 데이터가 쌓이지 않았어요\n코디를 더 등록해주세요")
            Spacer()
        }
        
    }
}
// MARK: OthersOOTDView
struct OthersOOTDView: View {
    @EnvironmentObject var homeMainVM: HomeMainViewModel
    var body: some View {
        VStack {
            Spacer()
            HStack(spacing: 3) {
                ForEach(homeMainVM.othersOOTD.indices, id: \.self) { index in
                    OOTDComponent(date: DateFormatter.dateOnly.string(from: homeMainVM.getDate(from: homeMainVM.othersOOTD[index].date)!), minTemp: nil, maxTemp: nil, ootdImageURL: homeMainVM.othersOOTD[index].imageURL)
                        .background(.ondosetBackground)
                }
            }
            .padding(3)
            .background(.white)
            Spacer()
        }
    }
}
// MARK: HomeBottomFooterView
struct HomeBottomFooterView: View {
    @Binding var currentPage: Int
    
    var body: some View {
        HStack {
            ForEach(0..<4) { page in
                Circle()
                    .fill(page == currentPage ? Color.main : Color.gray)
                    .frame(width: 5, height: 5)
                    .onTapGesture {
                        currentPage = page
                    }
            }
        }
        .padding()
    }
}

#Preview {
    HomeBottomView()
}
