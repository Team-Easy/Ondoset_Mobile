//
//  ClosetMainView.swift
//  Ondoset
//
//  Created by KoSungmin on 4/7/24.
//

import SwiftUI

struct ClosetMainView: View {
    // MARK: States
//    @State var selectedTab: Int = 1

    
    // mock data
//    @State var clothesData: [Clothes] = ClothesDTO.mockData()
    
//    @State var searchText: String = ""
    @StateObject var closetMainVM: ClosetMainViewModel = .init()
    @EnvironmentObject var wholeVM: WholeViewModel
    
    var body: some View {
        /// 각 탭의 메인 뷰마다 NavigationStack을 두는 것으로 설계합니다.
        
        // MARK: Main View
        NavigationStack {
            VStack(alignment: .center, spacing: 0) {
                SegmentControlComponent(selectedTab: $closetMainVM.selectedTab, tabMenus: MyClosetTab.allCases.map{$0.rawValue}, isMain: true)
                    .padding(.bottom, 15)
                
                SearchBarComponent(searchText: $closetMainVM.searchText, placeHolder: "등록한 옷을 검색하세요", searchAction: {
                    text in
                    print(text)
                })
                .padding(.horizontal, 18)
                
                if closetMainVM.presentingClothesData.isEmpty {
                    VStack(alignment: .center) {
                        Spacer()
                        BlankDataIndicateComponent(explainText: "아직 등록된 옷이 없어요\n오른쪽 아래의 옷 추가 버튼을 눌러 옷을 추가해주세요")
                        Spacer()
                    }
                }
                else {
                    ScrollView(showsIndicators: false) {
                        
                        Spacer()
                        
                        LazyVStack(spacing: 16, content: {
                            
                            ForEach(closetMainVM.presentingClothesData, id: \.clothesId) { item in
                                ClothSelectedComponent(
                                    category: item.category,
                                    clothName: item.name,
                                    clothTag: item.tag,
                                    clothThickness: item.thickness ?? .NORMAL,
                                    width: screenWidth - 40,
                                    additionBtn: AnyView(ClothOptionButton(clothesId: item.clothesId))
                                )
                            }
                            if !(closetMainVM.clothesLastPage == -2) {
                                ProgressView()
                                    .onAppear {
                                        Task {
                                            await closetMainVM.loadMoreItems()
                                        }
                                    }
                            }
                        })
                        
                        Spacer()
                    }
                    .padding(.top, 15)
                    .padding(.bottom, tabBarHeight)
//                    Spacer(minLength: 60)
                }
            } // VStack
            .ignoresSafeArea(edges: .bottom)
        }
        .overlay{
            Button(action: {
                self.closetMainVM.presentMyClothing = true
            }, label: {
                ZStack {
                    Circle()
                        .frame(width: 64, height: 64)
                        .foregroundStyle(.ondosetBackground)
                        .shadow(color: .gray.opacity(0.3), radius: 5, x: 1, y: 5)
                    Image(.icTop)
                        .frame(width: 40, height: 40)
                    Image(.addWhiteButton)
                        .frame(width: 12, height: 12)
                        .offset(x: 15, y: -15)
                }
            })
            .offset(x: screenWidth/2 - 50, y: screenHeight/2 - tabBarHeight - 50)
        }
        .overlay {
            if closetMainVM.presentAlert {
                AlertComponent(
                    showAlert: $closetMainVM.presentAlert,
                    alertTitle: "\(closetMainVM.getClothesName(by: closetMainVM.clothesIdWillDeleted)) 삭제",
                    alertContent: "삭제하면 취소할 수 없습니다.\n정말로 삭제하시겠습니까?",
                    rightBtnTitle: "삭제",
                    rightBtnAction: {
                        closetMainVM.deleteClothes(by: closetMainVM.clothesIdWillDeleted)
                    }
                )
            }
        }
        .sheet(isPresented: $closetMainVM.presentMyClothing) {
            NavigationView { MyClothingView(myClothingVM: .init(myClothing: closetMainVM.myClothing)) }
        }

    }
}

#Preview {
    ClosetMainView()
}
