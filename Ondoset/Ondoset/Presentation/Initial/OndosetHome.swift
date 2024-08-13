//
//  OndosetHome.swift
//  Ondoset
//
//  Created by KoSungmin on 4/10/24.
//

import SwiftUI

enum Tab {
    
    case home
    case record
    case closet
    case ootd
    case myPage
}

struct OndosetHome: View {
    
    @EnvironmentObject var wholeVM: WholeViewModel
    
    var body: some View {
        
        ZStack() {
            
            switch wholeVM.selectedTab {
            case .home:
                HomeMainView()
            case .record:
                
                if wholeVM.goToCoordiThroughHome {
                    
                    CoordiMainView(selectedYear: wholeVM.selectedCoordiYear, selectedMonth: wholeVM.selectedCoordiMonth, selectedDays: wholeVM.selectedCoordiDay)
                    
                } else {
                    
                    CoordiMainView()
                }
                
//                if wholeVM.selectedCoordiDay != 0 && wholeVM.selectedCoordiMonth != 0 && wholeVM.selectedCoordiDay != 0 {
//                    
//                    CoordiMainView(selectedYear: wholeVM.selectedCoordiYear, selectedMonth: wholeVM.selectedCoordiMonth, selectedDays: wholeVM.selectedCoordiDay)
//                    
//                } else {
//                    CoordiMainView()
//                }
                
            case .closet:
                ClosetMainView()
            case .ootd:
                OOTDMainView()
            case .myPage:
                MyPageMainView()
            }
            
            VStack {
                Spacer()
                
                AppTabView(selectedTab: $wholeVM.selectedTab)
                    .hidden(wholeVM.isTabBarHidden)
                    .overlay {
                        if wholeVM.isTabBarAlertStatus {
                            Color.black.opacity(0.5)
                        } else {
                            Color.clear
                        }
                    }
            }
        }
    }
}

struct AppTabView: View {
    
    @Binding var selectedTab: Tab
    
    var body: some View {
        
        HStack {
            
            HStack {
                
                Spacer()
                
                Image(selectedTab == .home ? "tabBarHomeSelected" : "tabBarHomeUnselected")
                    .onTapGesture {
                        selectedTab = .home
                    }
                
                Spacer()
                
                Image(selectedTab == .record ? "tabBarRecordSelected" : "tabBarRecordUnselected")
                    .onTapGesture {
                        selectedTab = .record
                    }
                
                Spacer()
                
                Image(selectedTab == .closet ? "tabBarClosetSelected" : "tabBarClosetUnselected")
                    .onTapGesture {
                        selectedTab = .closet
                    }
                
                Spacer()
                
                Image(selectedTab == .ootd ? "tabBarOOTDSelected" : "tabBarOOTDUnselected")
                    .onTapGesture {
                        selectedTab = .ootd
                    }
                
                Spacer()
                
                Image(selectedTab == .myPage ? "tabBarMyPageSelected" : "tabBarMyPageUnselected")
                    .onTapGesture {
                        selectedTab = .myPage
                    }
                
                Spacer()
                
            } // HStack
            .offset(y: -10)
        }
        .frame(width: screenWidth, height: tabBarHeight)
        .background(Color(hex: 0xF8F8F8))
    }
}

#Preview {
    OndosetHome()
}
