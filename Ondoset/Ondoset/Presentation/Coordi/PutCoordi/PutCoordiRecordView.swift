//
//  PutCoordiRecordView.swift
//  Ondoset
//
//  Created by KoSungmin on 5/11/24.
//

import SwiftUI

struct PutCoordiRecordView: View {
    
    // 기존에 선택된 옷 리스트 표시 딕셔너리
    @State var selectedClothes: [Int: Bool] = [:]
    
    // 수정하는 코디 아이디
    @Binding var selectedCoordiId: Int
    
    // 기존에 선택된 옷 리스트
    @Binding var coordiClothesList: [Clothes]
    
    // 수정하기 버튼 활성화 여부
    @State var putBtnAvailable: Bool = false
    
    // 카테고리 선택 탭
    @State var selectedTab: Int = 0
    
    // 검색창 텍스트
    @State var searchText: String = ""
    
    // 코디 수정 sheet 내리기 여부
    @Binding var isPutCoordiRecordSheetPresented: Bool
    
    @State var isLongPressed: Bool = false
    @State var longPressedCloth: Clothes = Clothes(clothesId: 0, name: "", category: .ACC, tag: "", tagId: 0)
    
    @State var isPostBtnAvailable: Bool = true
    
    @StateObject var putCoordiRecordVM: PutCoordiRecordViewModel = .init()
    
    let columns: [GridItem] = Array(repeating: .init(.fixed((screenWidth - 36)/3), spacing: 10), count: 3)
    
    
    var body: some View {
        
        VStack {
            
            navigationTopBar
            
            SegmentControlComponent(selectedTab: $selectedTab, tabMenus: MyClosetTab.allCases.map{$0.rawValue}, isMain: true)
                .onChange(of: selectedTab) { _ in
                    
                    Task {
                        
                        switch selectedTab {
                            
                        case 1:
                            await putCoordiRecordVM.getAllClothesByCategory(category: .TOP, lastPage: putCoordiRecordVM.getAllClothesByTopLastPage)
                        
                        case 2:
                            await putCoordiRecordVM.getAllClothesByCategory(category: .BOTTOM, lastPage: putCoordiRecordVM.getAllClothesByBottomLastPage)
                            
                        case 3:
                            await putCoordiRecordVM.getAllClothesByCategory(category: .OUTER, lastPage: putCoordiRecordVM.getAllClothesByOuterLastPage)
                            
                        case 4:
                            await putCoordiRecordVM.getAllClothesByCategory(category: .SHOE, lastPage: putCoordiRecordVM.getAllClothesByShoeLastPage)
                        
                        case 5:
                            await putCoordiRecordVM.getAllClothesByCategory(category: .ACC, lastPage: putCoordiRecordVM.getAllClothesByAccLastPage)
               
                        default:
                            await putCoordiRecordVM.getAllClothes(lastPage: putCoordiRecordVM.getAllClothesLastPage)
                        }
                        
                    }
                    print("탭 넘버: \(selectedTab)")
                    
                }
            
            SearchBarComponent(searchText: $searchText, placeHolder: "등록한 옷을 검색하세요") { text in
                
                Task {
                    
                    switch selectedTab {
                        
                    case 1:
                        await putCoordiRecordVM.searchClothByKeyword(category: .TOP, clothesName: text)
                        
                    case 2:
                        await putCoordiRecordVM.searchClothByKeyword(category: .BOTTOM, clothesName: text)
                        
                    case 3:
                        await putCoordiRecordVM.searchClothByKeyword(category: .OUTER, clothesName: text)
                        
                    case 4:
                        await putCoordiRecordVM.searchClothByKeyword(category: .SHOE, clothesName: text)

                    case 5:
                        await putCoordiRecordVM.searchClothByKeyword(category: .ACC, clothesName: text)
                        
                    default:
                        await putCoordiRecordVM.searchClothByKeyword(category: nil, clothesName: text)
                    }
                }
            }
            .frame(width: screenWidth - 20)
            
            ZStack {
                
                ScrollView(showsIndicators: false) {
                    
                    LazyVGrid(columns: columns, spacing: 10) {
                        
                        ForEach(putCoordiRecordVM.clothesList, id: \.self) { cloth in
                            
                            ZStack {
                                
                                let longPressGesture = LongPressGesture(minimumDuration: 1)
                                    .onChanged { _ in
                                        
                                        if !isLongPressed {
                                            
                                            isLongPressed = true
                                            self.longPressedCloth = cloth
                                            print("롱 프레스가 인식되고 있습니다.")
                                        }
                                        
                                    }
                                    .onEnded { _ in
                                        
                                        isLongPressed = false
                                        print("롱 프레스가 종료되었습니다.")
                                    }
                                
                                let tapGesture = TapGesture()
                                    .onEnded {
                                        selectedClothes[cloth.clothesId] = true
                                        
                                        coordiClothesList.append(cloth)
                                        
                                        // coordiClothesList.append(cloth)
                                    }
                                
                                
                                ClothSearchComponent(clothes: cloth)
                                    .gesture(
//                                        longPressGesture.exclusively(before: tapGesture)
                                        tapGesture.exclusively(before: longPressGesture)
                                    )

                                if selectedClothes[cloth.clothesId] ?? false {
                                    
                                    Color.black.opacity(0.3)
                                        .edgesIgnoringSafeArea(.all)
                                        .cornerRadius(10)
                                        .onTapGesture {
                                            selectedClothes[cloth.clothesId] = false
                                            
                                            coordiClothesList.removeAll { $0 == cloth }
                                            
                                            // coordiClothesList.removeAll { $0 == cloth }
                                        }
                                    
                                    Image("clothCheck")
                                }
                                
                            }
                        }
                    }
                } // ScrollView
                
                if isLongPressed {
                    
                    ClothDetailComponent(clothes: longPressedCloth)
                        .frame(width: screenWidth - 90)
                }
                
            } // ZStack
            
            Spacer()
            
            ButtonComponent(isBtnAvailable: $isPostBtnAvailable, width: screenWidth - 50, btnText: "저장하기", radius: 15) {
                
                Task {
                    
                    let coordClothesList = coordiClothesList.map { $0.clothesId }
                    
                    let result = await putCoordiRecordVM.putCoordi(coordiId: selectedCoordiId, coordiClothesList: coordClothesList)
                    
                    if result {
                        
                        isPutCoordiRecordSheetPresented = false
                        
                    }
                }
            }
        }
        .onAppear {
            
            // coordiClothesList에 있는 것들을 전부 selectedClothes[clothesId] = true로 바꿔야 함
            for cloth in coordiClothesList {
                
                selectedClothes[cloth.clothesId] = true
            }
        }
    }
    
    var navigationTopBar: some View {
        HStack {
            
            Button {
                
                isPutCoordiRecordSheetPresented.toggle()
                
            } label: {
                Text("닫기")
                    .padding(.leading, 15)
                    .font(Font.pretendard(.regular, size: 17))
                    .foregroundStyle(.darkGray)
            }
            
            Spacer()

        }
        .padding(.top, 15)
        .overlay {
            
            Text("나의 코디 수정하기")
                .font(Font.pretendard(.semibold, size: 17))
                .foregroundStyle(.black)
                .padding(.top, 10)
        }
    }
}

#Preview {
    PutCoordiRecordView(selectedCoordiId: .constant(0),coordiClothesList: .constant([]), isPutCoordiRecordSheetPresented: .constant(true))
}
