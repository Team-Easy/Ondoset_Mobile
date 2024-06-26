//
//  AddCoordiView.swift
//  Ondoset
//
//  Created by KoSungmin on 5/7/24.
//

import SwiftUI

struct AddCoordiRecordView: View {
    
    @StateObject var addCoordiRecordVM: AddCoordiRecordViewModel = .init()
    @EnvironmentObject var coordiMainVM: CoordiMainViewModel
    
    @State var searchText: String = ""
    @State var nextBtnAvailable: Bool = false
    
    @State var selectedClothes: [Int:Bool] = [:]
    
    @State var isLongPressed: Bool = false
    @State var longPressedCloth: Clothes = Clothes(clothesId: 0, name: "", category: .ACC, tag: "", tagId: 0)
    
    // 코디를 등록하려는 날짜
    @Binding var coordiYear: Int
    @Binding var coordiMonth: Int
    @Binding var coordiDay: Int
    
    // 뒤로 가기 sheet 내리기 여부
    @Binding var isAddCoordiRecordSheetPresented: Bool
    
    // 외출 출발 시간
    @State var departTime: Int = 0
    
    // 외출 도착 시간
    @State var arrivalTime: Int = 0
    
    @State var pickerDepartTime: Int = -1
    @State var pickerArrivalTime: Int = -1
    
    @State var locationSearchText: String = "지역 검색"     // 장소 검색 텍스트
    @State var lat: Double = 91.0       // 위도
    @State var lon: Double = 91.0       // 경도
    
    @State var clothesList: [Clothes] = []
    
    
    let columns: [GridItem] = Array(repeating: .init(.fixed((screenWidth - 36)/3), spacing: 10), count: 3)
    
    var body: some View {
        
        NavigationStack {
            
            VStack {
                navigationTopBar
                
                SegmentControlComponent(selectedTab: $addCoordiRecordVM.selectedTab, tabMenus: MyClosetTab.allCases.map{$0.rawValue}, isMain: true)
                    .onChange(of: addCoordiRecordVM.selectedTab) { _ in
                        
                        Task {
                            
                            switch addCoordiRecordVM.selectedTab {
                                
                            case 1:
                                
                                addCoordiRecordVM.getAllClothesByTopLastPage = -1
                                
                                addCoordiRecordVM.clothesList.removeAll()
                                
                                await addCoordiRecordVM.getAllClothesByCategory(category: .TOP, lastPage: addCoordiRecordVM.getAllClothesByTopLastPage)
                            
                            case 2:
                                
                                addCoordiRecordVM.getAllClothesByBottomLastPage = -1
                                
                                addCoordiRecordVM.clothesList.removeAll()
                                
                                await addCoordiRecordVM.getAllClothesByCategory(category: .BOTTOM, lastPage: addCoordiRecordVM.getAllClothesByBottomLastPage)
                                
                            case 3:
                                
                                addCoordiRecordVM.getAllClothesByOuterLastPage = -1
                                
                                addCoordiRecordVM.clothesList.removeAll()
                                
                                await addCoordiRecordVM.getAllClothesByCategory(category: .OUTER, lastPage: addCoordiRecordVM.getAllClothesByOuterLastPage)
                                
                            case 4:
                                
                                addCoordiRecordVM.getAllClothesByShoeLastPage = -1
                                
                                addCoordiRecordVM.clothesList.removeAll()
                                
                                await addCoordiRecordVM.getAllClothesByCategory(category: .SHOE, lastPage: addCoordiRecordVM.getAllClothesByShoeLastPage)
                            
                            case 5:
                                
                                addCoordiRecordVM.getAllClothesByAccLastPage = -1
                                
                                addCoordiRecordVM.clothesList.removeAll()
                                
                                await addCoordiRecordVM.getAllClothesByCategory(category: .ACC, lastPage: addCoordiRecordVM.getAllClothesByAccLastPage)
                   
                            default:
                                
                                addCoordiRecordVM.getAllClothesLastPage = -1
                                
                                addCoordiRecordVM.clothesList.removeAll()
                                
                                await addCoordiRecordVM.getAllClothes(lastPage: addCoordiRecordVM.getAllClothesLastPage)
                            }
                            
                        }
                        print("탭 넘버: \(addCoordiRecordVM.selectedTab)")
                        
                    }
                
                SearchBarComponent(searchText: $searchText, placeHolder: "등록한 옷을 검색하세요") { text in
                    
                    Task {
                        
                        switch addCoordiRecordVM.selectedTab {
                            
                        case 1:
                            await addCoordiRecordVM.searchClothByKeyword(category: .TOP, clothesName: text)
                            
                        case 2:
                            await addCoordiRecordVM.searchClothByKeyword(category: .BOTTOM, clothesName: text)
                            
                        case 3:
                            await addCoordiRecordVM.searchClothByKeyword(category: .OUTER, clothesName: text)
                            
                        case 4:
                            await addCoordiRecordVM.searchClothByKeyword(category: .SHOE, clothesName: text)

                        case 5:
                            await addCoordiRecordVM.searchClothByKeyword(category: .ACC, clothesName: text)
                            
                        default:
                            await addCoordiRecordVM.searchClothByKeyword(category: nil, clothesName: text)
                        }
                    }
                }
                .frame(width: screenWidth - 20)
                
                ZStack {
                    
                    ScrollView(showsIndicators: false) {
                        
                        LazyVGrid(columns: columns, spacing: 10) {
                            
                            ForEach(addCoordiRecordVM.clothesList.indices, id: \.self) { index in
                                
                                ZStack {
                                    
                                    ClothSearchComponent(clothes: addCoordiRecordVM.clothesList[index])
                                        .onAppear {
                                            if index == addCoordiRecordVM.clothesList.count - 1 {
                                                Task {
                                                    
                                                    switch addCoordiRecordVM.selectedTab {
                                                        
                                                    case 1:
                                                        await addCoordiRecordVM.getAllClothesByCategory(category: .TOP, lastPage: addCoordiRecordVM.getAllClothesByTopLastPage)
                                                        
                                                    case 2:
                                                        await addCoordiRecordVM.getAllClothesByCategory(category: .BOTTOM, lastPage: addCoordiRecordVM.getAllClothesByBottomLastPage)
                                                        
                                                    case 3:
                                                        await addCoordiRecordVM.getAllClothesByCategory(category: .OUTER, lastPage: addCoordiRecordVM.getAllClothesByOuterLastPage)
                                                        
                                                    case 4:
                                                        await addCoordiRecordVM.getAllClothesByCategory(category: .SHOE, lastPage: addCoordiRecordVM.getAllClothesByShoeLastPage)
                                                        
                                                    case 5:
                                                        await addCoordiRecordVM.getAllClothesByCategory(category: .ACC, lastPage: addCoordiRecordVM.getAllClothesByAccLastPage)
                                                        
                                                    default:
                                                        await addCoordiRecordVM.getAllClothes(lastPage: addCoordiRecordVM.getAllClothesLastPage)
                                                    }
                                                }
                                            }
                                        }
                                        .onTapGesture {
                                            selectedClothes[addCoordiRecordVM.clothesList[index].clothesId] = true
                                            
                                            addCoordiRecordVM.coordiClothesList.append(addCoordiRecordVM.clothesList[index])
                                        }

                                    if selectedClothes[addCoordiRecordVM.clothesList[index].clothesId] ?? false {
                                        
                                        Color.black.opacity(0.3)
                                            .edgesIgnoringSafeArea(.all)
                                            .cornerRadius(10)
                                            .onTapGesture {
                                                selectedClothes[addCoordiRecordVM.clothesList[index].clothesId] = false
                                                
                                                addCoordiRecordVM.coordiClothesList.removeAll { $0 == addCoordiRecordVM.clothesList[index] }
                                                
                                                // coordiClothesList.removeAll { $0 == cloth }
                                            }
                                        
                                        Image("clothCheck")
                                    }
                                    
                                }
                                .onChange(of: addCoordiRecordVM.coordiClothesList) { _ in
                                    
                                    print(addCoordiRecordVM.coordiClothesList)
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
                
                NavigationLink(destination: AddCoordiRecordSecondView(addCoordiRecordVM: addCoordiRecordVM, departTime: $departTime, arrivalTime: $arrivalTime, pickerDepartTime: $pickerDepartTime, pickerArrivalTime: $pickerArrivalTime, coordiYear: $coordiYear, coordiMonth: $coordiMonth, coordiDay: $coordiDay, isAddCoordiRecordSheetPresented: $isAddCoordiRecordSheetPresented, locationSearchText: $locationSearchText, lat: $lat, lon: $lon).environmentObject(coordiMainVM)) {
                    Rectangle()
                        .foregroundStyle(nextBtnAvailable ? .main : .lightGray)
                        .frame(width: screenWidth - 50, height: 50)
                        .cornerRadius(15)
                        .overlay(
                            Text("다음으로")
                                .font(Font.pretendard(.bold, size: 17))
                                .foregroundStyle(nextBtnAvailable ? .white : .darkGray)
                        )
                }.disabled(!nextBtnAvailable)
            }
            .padding(.bottom, 10)
            .onAppear {

            }
            .onChange(of: addCoordiRecordVM.coordiClothesList) { _ in
                
                updateBtnAvailable()
            }
        }
    }
    
    var navigationTopBar: some View {
        HStack {
            
            Button {
                
                isAddCoordiRecordSheetPresented.toggle()
                
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
            
            Text("나의 코디 추가하기")
                .font(Font.pretendard(.semibold, size: 17))
                .foregroundStyle(.black)
                .padding(.top, 10)
        }
    }
    
    private func updateBtnAvailable() {
        
        if addCoordiRecordVM.coordiClothesList != [] {
            
            nextBtnAvailable = true
        } else {
            nextBtnAvailable = false
        }
    }
}

//#Preview {
//    AddCoordiRecordView(longPressedCloth: Clothes(clothesId: 1, name: "엄마가 사주신 검은 미키마우스 티셔츠", category: .SHOE, tag: "상의 태그", tagId: 1), isAddCoordiRecordSheetPresented: .constant(true))
//}
