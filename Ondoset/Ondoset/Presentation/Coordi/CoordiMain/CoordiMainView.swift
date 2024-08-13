//
//  CoordiMainView.swift
//  Ondoset
//
//  Created by KoSungmin on 5/4/24.
//

import SwiftUI
import Kingfisher

struct CoordiMainView: View {
    
    // 코디 기록 추가하기 sheet 활성화 여부
    @State var isAddCoordiRecordSheetPresented: Bool = false
    
    // 코디 계획 추가하기 sheet 활성화 여부
    @State var isAddCoordiPlanSheetPresented: Bool = false
    
    // 상단 연도 피커 보이기 여부
    @State var showYearPicker: Bool = false
    
    @State var selectedYear: Int = 2024
    @State var selectedMonth: Int = 8
    @State private var currentIndex: Int = 0
    @State var selectedDays = 1
    @State private var selectedWeekday = "Mon"
    @State private var selectedSatisfaction: Satisfaction?
    
    // 사진 보관함 활성화 여부
    @State private var openPhoto: Bool = false
    @State private var coordiImage: UIImage = UIImage()
    
    @State private var showSelectedSatisfaction = false
    
    @State var showCoordiDeleteAlert: Bool = false
    @State var willDeleteCoordiId: Int = 0
    
    // MARK: 코디 수정하기
    // 코디 수정하기 옷 리스트
    @State var coordiClothesList: [Clothes] = []
    // 코디 수정하기 코디 번호
    @State var selectedCoordiId: Int = 0
    // 코디 기록 수정하기 sheet 활성화 여부
    @State var isPutCoordiRecordSheetPresented: Bool = false
    
    
    // MARK: 외출 시간 등록/수정하기
    @State var isRegisterGoOutTimeSheetPresented: Bool = false
    @State var isPutGoOutTimeSheetPresented: Bool = false
    
    // 외출 출발 시간
    @State var goOutDepartTime: Int = -1
    @State var goOutArrivalTime: Int = -1
    @State var goOutRegion: String = "지역 검색"
    @State var toSetTimeCoordiId: Int = 0
    
    
    let month = Array(1...12)
    let years = Array(1900...2100)
//    @State var days: [Int] = []
    @State var days: [(day: Int, weekday: String)] = []
    
    @StateObject var coordiMainVM: CoordiMainViewModel = .init()
    @EnvironmentObject var wholeVM: WholeViewModel
    
    var body: some View {
        
        NavigationStack {
            
            ZStack {
                
                GeometryReader { fullView in
                    
                    VStack(spacing: 0) {
                        
                        coordiHeaderView
                        
                        coordiMonthView
                        
                        coordiDayView
                        
                        Rectangle()
                            .frame(width: screenWidth, height: 3)
                            .foregroundStyle(Color(hex: 0xEDEEFA))
                            .padding(.vertical, 5)
                            .padding(.bottom, 10)
                        
                        VStack {
                            
                            ForEach(days, id: \.day) { day in

                                    if self.selectedDays == day.day {
                                        
                                        HStack(spacing: 7) {
                                            
                                            if let coordiRecord = coordiMainVM.coordiRecord.first(where: {$0.year == selectedYear && $0.month == selectedMonth && $0.day == day.day}) {
                                                
                                                if let satisfaction = coordiRecord.satisfaction {

                                                    HStack {
                                                        
                                                        if showSelectedSatisfaction {
                                                            
                                                            HStack(spacing: 7) {
                                                                
                                                                ForEach(Satisfaction.allCases, id: \.self) { satisfaction in
                                                                    
                                                                    satisfaction.image
                                                                        .onTapGesture {
                                                                            
                                                                            // 만족도 수정 API
                                                                            Task {
                                                                                
                                                                                let result = await coordiMainVM.setSatisfaction(coordiId: coordiRecord.coordiId, satisfaction: satisfaction)
                                                                                
                                                                                if result {
                                                                                    
                                                                                    selectedSatisfaction = satisfaction
                                                                                    
                                                                                    await coordiMainVM.getCoordiRecord(year: selectedYear, month: selectedMonth)
                                                                                }
                                                                            }
                                                                            showSelectedSatisfaction = false
                                                                            // 만족도 저장 API
                                                                        }
                                                                }
                                                            }
                                                            .cornerRadius(40)
                                                            .shadow(color: Color(hex: 0xEDEEFA), radius: 4)
                                                            
                                                        } else {
                                                            
                                                            HStack {
                                                                selectedSatisfaction?.image
                                                                    .resizable()
                                                                    .frame(width: 30, height: 30)
                                                                    
                                                                
                                                                if let title = selectedSatisfaction?.title {
                                                                    Text(title)
                                                                        .font(Font.pretendard(.bold, size: 13))
                                                                        .foregroundStyle(.main)
                                                                }
                                                            }
                                                            .onTapGesture {
                                                                
                                                                showSelectedSatisfaction = true
                                                            }
                                                        }

                                                        Spacer()
                                                        
                                                        CoordiImageView(openPhoto: $openPhoto, coordiRecord: coordiRecord)
                                                            .onChange(of: coordiImage) { image in
                                                                
                                                                if let imageData = coordiImage.jpegData(compressionQuality: 0.1) {
                                                                    
                                                                    Task {
                                                                        
                                                                        let result = await coordiMainVM.setCoordiImage(coordiId: coordiRecord.coordiId, image: imageData)
                                                                        
                                                                        print("이미지 변경: \(result)")
                                                                        
                                                                        if result {
                                                                            
                                                                            await coordiMainVM.getCoordiRecord(year: selectedYear, month: selectedMonth)
                                                                        }
                                                                    }
                                                                }
                                                            }
                                                        
                                                        Menu(content: {

                                                            Button {
                                                                
                                                                isPutCoordiRecordSheetPresented = true
                                                                
                                                                selectedCoordiId = coordiRecord.coordiId
                                                                
                                                                coordiClothesList = coordiRecord.clothesList
                                                                
                                                            } label: {
                                                                Text("코디 수정하기")
                                                            }
                                                            
                                                            Button {
                                                                
                                                                isPutGoOutTimeSheetPresented = true
                                                                goOutRegion = coordiRecord.region ?? "지역 검색"
                                                                goOutDepartTime = coordiRecord.departTime ?? 0
                                                                goOutArrivalTime = coordiRecord.arrivalTime ?? 0
                                                                
                                                                toSetTimeCoordiId = coordiRecord.coordiId
                                                                
                                                            } label: {
                                                                Text("외출 시간 수정하기")
                                                            }
                                                            
                                                            Button {
                                                                
                                                                isAddCoordiPlanSheetPresented = true
                                                                
                                                                coordiClothesList = coordiRecord.clothesList
                                                                
                                                            } label: {
                                                                Text("오늘 코디로 가져오기")
                                                            }
                                                            
                                                            Button(role: .destructive) {
                                                                
                                                                showCoordiDeleteAlert = true
                                                                willDeleteCoordiId = coordiRecord.coordiId
                                                                
                                                            } label: {
                                                                Text("코디 삭제하기")
                                                            }

                                                        }, label: {
                                                            Image(systemName: "ellipsis")
                                                                .frame(width:24, height: 24)
                                                                .rotationEffect(.degrees(90))
                                                                .foregroundColor(.gray)
                                                                .clipShape(Circle())
                                                        })
                                                    }
                                                    .frame(width: screenWidth - 40, height: 50)
                                                    .onAppear {
                                                        selectedSatisfaction = satisfaction
                                                        print(selectedSatisfaction)
                                                    }
                                                    .onDisappear {
                                                        showSelectedSatisfaction = false
                                                    }
                                                } else if let departTime = coordiRecord.departTime, let arrivalTime = coordiRecord.arrivalTime {

                                                    HStack  {
                                                        if showSelectedSatisfaction {
                                                            
                                                            HStack(spacing: 7) {
                                                                
                                                                ForEach(Satisfaction.allCases, id: \.self) { satisfaction in
                                                                    
                                                                    satisfaction.image
                                                                        .onTapGesture {
                                                                            
                                                                            // 만족도 등록
                                                                            Task {

                                                                                let result = await coordiMainVM.setSatisfaction(coordiId: coordiRecord.coordiId, satisfaction: satisfaction)
                                                                                
                                                                                if result {
                                                                                    await coordiMainVM.getCoordiRecord(year: selectedYear, month: selectedMonth)
                                                                                }
                                                                            }
                                                                            showSelectedSatisfaction = false
                                                                        }
                                                                }
                                                            }
                                                            .cornerRadius(40)
                                                            .shadow(color: Color(hex: 0xEDEEFA), radius: 4)
                                                            
                                                        } else {
                                                            
                                                            Group {
                                                                Image("addBtnWhite")
                                                                    .resizable()
                                                                    .frame(width: 35, height: 35)
                                                                    .shadow(color: Color(hex: 0x5E617B), radius: 1, y: 1)
                                                                    
                                                                
                                                                Text("만족도를 선택해주세요")
                                                                    .font(Font.pretendard(.bold, size: 13))
                                                                    .foregroundStyle(.main)
                                                            }
                                                            .onTapGesture {
                                                                
                                                                showSelectedSatisfaction = true
                                                                
                                                            }
                                                        }
                                                        
                                                        Spacer()
                                                        
                                                        CoordiImageView(openPhoto: $openPhoto, coordiRecord: coordiRecord)
                                                            .onChange(of: coordiImage) { image in
                                                                
                                                                if let imageData = coordiImage.jpegData(compressionQuality: 0.1) {
                                                                    
                                                                    Task {
                                                                        
                                                                        let result = await coordiMainVM.setCoordiImage(coordiId: coordiRecord.coordiId, image: imageData)
                                                                        
                                                                        print("이미지 변경: \(result)")
                                                                        
                                                                        if result {
                                                                            
                                                                            await coordiMainVM.getCoordiRecord(year: selectedYear, month: selectedMonth)
                                                                        }
                                                                    }
                                                                }
                                                            }
                                                        
                                                        Menu(content: {

                                                            Button {
                                                                
                                                                isPutCoordiRecordSheetPresented = true
                                                                
                                                                selectedCoordiId = coordiRecord.coordiId
                                                                
                                                                coordiClothesList = coordiRecord.clothesList
                                                                
                                                            } label: {
                                                                Text("코디 수정하기")
                                                            }
                                                            
                                                            Button {
                                                                
                                                                isPutGoOutTimeSheetPresented = true
                                                                
                                                                goOutRegion = coordiRecord.region ?? "지역 검색"
                                                                goOutDepartTime = coordiRecord.departTime ?? 0
                                                                goOutArrivalTime = coordiRecord.arrivalTime ?? 0
                                                                
                                                                toSetTimeCoordiId = coordiRecord.coordiId
                                                                
                                                            } label: {
                                                                Text("외출 시간 수정하기")
                                                            }
                                                            
                                                            Button {
                                                                
                                                                isAddCoordiPlanSheetPresented = true
                                                                
                                                                
                                                                coordiClothesList = coordiRecord.clothesList
                                                                
                                                                
                                                            } label: {
                                                                Text("오늘 코디로 가져오기")
                                                            }
                                                            
                                                            Button(role: .destructive) {
                                                                
                                                                showCoordiDeleteAlert = true
                                                                willDeleteCoordiId = coordiRecord.coordiId
                                                                
                                                            } label: {
                                                                Text("코디 삭제하기")
                                                            }

                                                        }, label: {
                                                            Image(systemName: "ellipsis")
                                                                .frame(width:24, height: 24)
                                                                .rotationEffect(.degrees(90))
                                                                .foregroundColor(.gray)
                                                                .clipShape(Circle())
                                                        })
                                                    }
                                                    .frame(width: screenWidth - 40, height: 50)
                                                    .onDisappear {
                                                        showSelectedSatisfaction = false
                                                    }
                                                    
                                                } else if coordiRecord.clothesList != [] {
                                                    
                                                    if isDatePast(year: coordiRecord.year, month: coordiRecord.month, day: coordiRecord.day) {
                                                        
                                                        HStack {
                                                            Circle()
                                                                .frame(width: 25, height: 25)
                                                                .foregroundStyle(.white)
                                                                .shadow(color: Color(hex: 0x5E617B), radius: 1, y: 1)
                                                            
                                                            Text("외출 시간을 먼저 등록해주세요")
                                                                .font(Font.pretendard(.bold, size: 13))
                                                                .foregroundStyle(.main)
                                                                .frame(width: 175, alignment: .leading)
                                                            
                                                            
                                                            Spacer()
                                                            
                                                            CoordiImageView(openPhoto: $openPhoto, coordiRecord: coordiRecord)
                                                                .onChange(of: coordiImage) { image in
                                                                    
                                                                    if let imageData = coordiImage.jpegData(compressionQuality: 0.1) {
                                                                        
                                                                        Task {
                                                                            
                                                                            let result = await coordiMainVM.setCoordiImage(coordiId: coordiRecord.coordiId, image: imageData)
                                                                            
                                                                            print("이미지 변경: \(result)")
                                                                            
                                                                            if result {
                                                                                
                                                                                await coordiMainVM.getCoordiRecord(year: selectedYear, month: selectedMonth)
                                                                            }
                                                                        }
                                                                    }
                                                                }
                                                            
                                                            Menu(content: {

                                                                Button {
                                                                    
                                                                    isPutCoordiRecordSheetPresented = true
                                                                    
                                                                    selectedCoordiId = coordiRecord.coordiId
                                                                    
                                                                    coordiClothesList = coordiRecord.clothesList
                                                                    
                                                                } label: {
                                                                    Text("코디 수정하기")
                                                                }
                                                                
                                                                Button {
                                                                    
                                                                    isRegisterGoOutTimeSheetPresented = true
                                                                    
                                                                    goOutRegion = coordiRecord.region ?? "지역 검색"
                                                                    
                                                                    toSetTimeCoordiId = coordiRecord.coordiId
                                                                    
                                                                } label: {
                                                                    Text("외출 시간 등록하기")
                                                                }
                                                                
                                                                Button {
                                                                    
                                                                    isAddCoordiPlanSheetPresented = true
                                                                    
                                                                    coordiClothesList = coordiRecord.clothesList
                                                                    
                                                                } label: {
                                                                    Text("오늘 코디로 가져오기")
                                                                }
                                                                
                                                                Button(role: .destructive) {
                                                                    
                                                                    showCoordiDeleteAlert = true
                                                                    willDeleteCoordiId = coordiRecord.coordiId
                                                                    
                                                                } label: {
                                                                    Text("코디 삭제하기")
                                                                }

                                                            }, label: {
                                                                Image(systemName: "ellipsis")
                                                                    .frame(width:24, height: 24)
                                                                    .rotationEffect(.degrees(90))
                                                                    .foregroundColor(.gray)
                                                                    .clipShape(Circle())
                                                            })
                                                        } //Group
    //                                                    .offset(y: -8)
                                                        .frame(width: screenWidth - 40, height: 50)
                                                    } else {
                                                        
                                                        HStack {
                                                            Circle()
                                                                .frame(width: 25, height: 25)
                                                                .foregroundStyle(.white)
                                                                .shadow(color: Color(hex: 0x5E617B), radius: 1, y: 1)
                                                            
                                                            Text("아직 만족도를 등록할 수 없어요")
                                                                .font(Font.pretendard(.bold, size: 13))
                                                                .foregroundStyle(.main)
                                                                .frame(width: 175, alignment: .leading)
                                                            
                                                            Spacer()
                                                            
                                                            Menu(content: {

                                                                Button {
                                                                    
                                                                    isPutCoordiRecordSheetPresented = true
                                                                    
                                                                    selectedCoordiId = coordiRecord.coordiId
                                                                    
                                                                    coordiClothesList = coordiRecord.clothesList
                                                                    
                                                                } label: {
                                                                    Text("코디 수정하기")
                                                                }
                                                                
                                                                Button(role: .destructive) {
                                                                    
                                                                    showCoordiDeleteAlert = true
                                                                    willDeleteCoordiId = coordiRecord.coordiId
                                                                    
                                                                } label: {
                                                                    Text("코디 삭제하기")
                                                                }

                                                            }, label: {
                                                                Image(systemName: "ellipsis")
                                                                    .frame(width:24, height: 24)
                                                                    .rotationEffect(.degrees(90))
                                                                    .foregroundColor(.gray)
                                                                    .clipShape(Circle())
                                                            })
                                                        }

                                                        .frame(width: screenWidth - 40, height: 50)
                                                    }
                                                     
                                                }
                                            } else {
                                                
                                                HStack {
                                                    Circle()
                                                        .frame(width: 25, height: 25)
                                                        .foregroundStyle(.white)
                                                        .shadow(color: Color(hex: 0x5E617B), radius: 1, y: 1)

                                                    Text("코디를 먼저 등록해주세요")
                                                        .font(Font.pretendard(.bold, size: 13))
                                                        .foregroundStyle(.main)
                                                    
                                                    Spacer()
                                                }
                                                .frame(width: screenWidth - 40, height: 50)
                                                
                                                
                                            }
                                            
                                        } // HStack
                                        .frame(width: screenWidth * 0.9)
                                        
                                        TabView(selection: $selectedDays) {
                                            
                                            if let coordiRecord = coordiMainVM.coordiRecord.first(where: {$0.year == selectedYear && $0.month == selectedMonth && $0.day == day.day}) {
                                                
                                                VStack(spacing: 0) {
                                                    
                                                    ScrollView(showsIndicators: false) {
                                                        
                                                        ForEach(coordiRecord.clothesList, id: \.self) { cloth in
                                                            
                                                            ClothSelectedComponent(category: cloth.category, clothName: cloth.name, clothTag: cloth.tag, clothThickness: cloth.thickness ?? nil, width: screenWidth - 50)
                                                    
                                                        }
                                                    }
                                                    .tag(coordiRecord.day)
                                                    .padding(.bottom, tabBarHeight)
                                                    
                                                    Spacer()
                                                }
                                                .ignoresSafeArea(edges: .bottom)
                                                
                                            } else {
                                                
                                                VStack {
                                                    
                                                    // 나의 코디 추가하기 버튼
                                                    Image("addCoordiBtn")
                                                        .onTapGesture {
                                                            
                                                            if isDatePast(year: selectedYear, month: selectedMonth, day: selectedDays) {
                                                                
                                                                isAddCoordiRecordSheetPresented = true
                                                                
                                                            } else {
                                                                isAddCoordiPlanSheetPresented = true
                                                            }
                                                            
                                                        }
                                                    
                                                    Spacer()
                                                }
                                                .tag(day.day)
                                                
                                            }
      
                                        }
                                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                                        .animation(.default, value: selectedDays)
                                        
                                    }
                   
                            } // ForEach
           
                        } // VStack
//                        .ignoresSafeArea(edges: .bottom)
                    }
                } // GeometryReader

                if showCoordiDeleteAlert {
                    AlertComponent(wholeVM: _wholeVM, showAlert: $showCoordiDeleteAlert, alertTitle: "코디 삭제", alertContent: "삭제하면 취소할 수 없습니다. \n정말로 삭제하시겠습니까?", rightBtnTitle: "확인") {
                        
                        Task {
                            let result = await coordiMainVM.deleteCoordi(coordi: willDeleteCoordiId)
                            
                            if result {
                                await coordiMainVM.getCoordiRecord(year: selectedYear, month: selectedMonth)
                                
                                showCoordiDeleteAlert = false
                                
                            }
                        }
                        
                    }
                } // GeometryReader
            } // ZStack
            .ignoresSafeArea(edges: .bottom)
        } // NavigationStack
        .sheet(isPresented: $openPhoto, content: {
            ImagePicker(sourceType: .photoLibrary, selectedImage: $coordiImage)
        })
        .sheet(isPresented: $isAddCoordiRecordSheetPresented) {
            AddCoordiRecordView(coordiYear: $selectedYear, coordiMonth: $selectedMonth, coordiDay:
                                    $selectedDays, isAddCoordiRecordSheetPresented: $isAddCoordiRecordSheetPresented)
            .environmentObject(coordiMainVM)
        }
        .sheet(isPresented: $isPutCoordiRecordSheetPresented) {
            
            PutCoordiRecordView(coordiYear: $selectedYear, coordiMonth: $selectedMonth, selectedCoordiId: $selectedCoordiId, coordiClothesList: $coordiClothesList, isPutCoordiRecordSheetPresented: $isPutCoordiRecordSheetPresented)
                .environmentObject(coordiMainVM)
        }
        .sheet(isPresented: $isPutGoOutTimeSheetPresented) {
            
            PutGoOutTimeView(selectedCoordiId: $toSetTimeCoordiId, selectedYear: $selectedYear, selectedMonth: $selectedMonth, selecteddDays: $selectedDays, goOutRegioin: $goOutRegion, goOutDepartTime: $goOutDepartTime, goOutArrivalTime: $goOutArrivalTime, isPutGoOutTimeSheetPresented: $isPutGoOutTimeSheetPresented)
                .presentationDetents([.height(screenHeight / 3)])
                .environmentObject(coordiMainVM)
            
        }
        .sheet(isPresented: $isRegisterGoOutTimeSheetPresented) {
            
            RegisterGoOutTimeView(selectedCoordiId: $toSetTimeCoordiId, selectedYear: $selectedYear, selectedMonth: $selectedMonth, selectedDays: $selectedDays, goOutRegion: $goOutRegion, isRegisterGoOutTimeSheetPresented: $isRegisterGoOutTimeSheetPresented)
                .presentationDetents([.height(screenHeight / 3)])
                .environmentObject(coordiMainVM)
        }
        .sheet(isPresented: $isAddCoordiPlanSheetPresented) {
            AddCoordiPlanView(isAddCoordiPlanSheetPresented: $isAddCoordiPlanSheetPresented, coordiYear: $selectedYear, coordiMonth: $selectedMonth, coordiDay: $selectedDays, coordiClothesList: $coordiClothesList)
                .environmentObject(coordiMainVM)
        }
        .onAppear {
            
//            if !wholeVM.goToCoordiThroughHome {
//                
//                let today = Date()
//                
//                selectedYear = Calendar.current.component(.year, from: today)
//                selectedMonth = Calendar.current.component(.month, from: today)
//                selectedDays = Calendar.current.component(.day, from: today)
//                
//                let weekday = Calendar.current.component(.weekday, from: today)
//                
//                selectedWeekday = weekdayString(from: weekday)
//                
//            } else {
//                
//                var components = DateComponents()
//                
//                selectedYear = wholeVM.selectedCoordiYear
//                selectedMonth = wholeVM.selectedCoordiMonth
//                selectedDays = wholeVM.selectedCoordiDay
//                
//                components.year = wholeVM.selectedCoordiYear
//                components.month = wholeVM.selectedCoordiMonth
//                components.day = wholeVM.selectedCoordiDay
//                
//                if let date = Calendar.current.date(from: components) {
//                    
//                    let weekday = Calendar.current.component(.weekday, from: date)
//                    
//                    selectedWeekday = weekdayString(from: weekday)
//                }
//            }
            
            let today = Date()
            
            if !wholeVM.goToCoordiThroughHome {
                
                selectedYear = Calendar.current.component(.year, from: today)
                selectedMonth = Calendar.current.component(.month, from: today)
                selectedDays = Calendar.current.component(.day, from: today)
                
            } else {
                
                print("선택된 날짜: \(wholeVM.selectedCoordiYear).\(wholeVM.selectedCoordiMonth).\(wholeVM.selectedCoordiDay)")

                selectedYear = wholeVM.selectedCoordiYear
                selectedMonth = wholeVM.selectedCoordiMonth
                selectedDays = wholeVM.selectedCoordiDay
            }
            
            let weekday = Calendar.current.component(.weekday, from: today)
            
            selectedWeekday = weekdayString(from: weekday)
        
            coordiClothesList = []
            
            let initialIndex = selectedMonth - 3
            currentIndex = max(0, min(initialIndex, month.count - 5))
            
            changeDays()
            
            // 코디 기록/계획 API 호출
            Task {
                await coordiMainVM.getCoordiRecord(year: selectedYear, month: selectedMonth)

            }
            
//            wholeVM.isTabBarHidden = true
        }
        .onChange(of: selectedYear) { _ in
            
            changeDays()
            
            Task {
                // 코디 기록 / 계획 조회 API 호출
                await coordiMainVM.getCoordiRecord(year: selectedYear, month: selectedMonth)
                showYearPicker = false
            }
        }
        .onChange(of: selectedMonth) { _ in
            
            changeDays()
            
            Task {
                await coordiMainVM.getCoordiRecord(year: selectedYear, month: selectedMonth)
            }
        }
        .onDisappear {
            
            wholeVM.goToCoordiThroughHome = false
        }
    }
    
    // MARK: 화면 헤더
    var coordiHeaderView: some View {
        
        HStack(spacing: 0) {
            
            Image("calendar")
            
            if showYearPicker {
                
                Picker(selection: $selectedYear, label: Text("Year")) {
                                ForEach(years, id: \.self) { year in
                                    Text(String(format: "%04d", year))
                                }
                            }
                            .labelsHidden()
                            .padding()
                            .tint(.main)
                
            } else {
                
                HStack {
                    Text(String(format: "%04d", selectedYear))
                        
                    
                    Image("bottomChevron")
                    
                }
                .onTapGesture {
                    showYearPicker.toggle()
                }
                .frame(width: 115.5, height: 66)

            }
            
            Spacer()
        }
        .padding(.horizontal, 25)
    }
    
    // MARK: 월 스크롤 뷰
    var coordiMonthView: some View {
        
        Rectangle()
            .foregroundStyle(Color(hex: 0xEDEEFA))
            .frame(height: screenHeight / 13)
            .overlay {
                
                // MARK: 월 스크롤 뷰
                GeometryReader { geometry in
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 0) {
                            ForEach(month.indices, id: \.self) { index in
                                
                                Text("\(month[index])월")
                                    .frame(width: 70, height: 30)
                                    .font(month[index] == selectedMonth ? Font.pretendard(.semibold, size: 17) : Font.pretendard(.medium, size: 15))
                                    .foregroundStyle(month[index] == selectedMonth ? .black : .darkGray)
                                    .background(
                                        Rectangle() // 여기에 Rectangle을 사용하여 배경을 설정
                                            .foregroundColor(month[index] == selectedMonth ? Color(hex: 0xA8B9F5) : .clear)
                                            .cornerRadius(30) // 여기서 바로 cornerRadius를 적용
                                    )
                                    .frame(width: screenWidth / 5)
                                    .onTapGesture {
                                        
                                        withAnimation {
                                            selectedMonth = month[index]
                                            let newIndex = selectedMonth - 3  // month를 선택했을 때 중앙에 오도록
                                                    currentIndex = max(0, min(newIndex, month.count - 3))  // 범위 확인
                                                    withAnimation(.easeInOut(duration: 0.2)) {
                                                        currentIndex = newIndex
                                                    }
                                        }
                                    }
                            }
                        }
                        .frame(height: screenHeight / 13)
                        .background(Color(hex: 0xEDEEFA))

                    }
                    .content.offset(x: -CGFloat(currentIndex) * geometry.size.width / 5)
                    .gesture(
                        DragGesture().onEnded { value in
                            let dragThreshold = geometry.size.width / 5
                            if value.translation.width < -dragThreshold {
                                
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    if currentIndex < month.count - 3 {
                                        currentIndex += 1
                                        selectedMonth += 1
                                    }
                                }
                                
                            } else if value.translation.width > dragThreshold {
                                
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    if currentIndex > 0 {
                                        currentIndex -= 1
                                        selectedMonth -= 1
                                    }
                                }
                            }
                        }
                    )
                }
                
            }
    }
    
    // MARK: 일 스크롤 뷰
    var coordiDayView: some View {

        ScrollView(.horizontal, showsIndicators: false) {
            
            ScrollViewReader { value in
                
                HStack {
                    ForEach(days, id: \.day) { day in

                        VStack {
                            
                            if self.selectedDays != day.day {
                                
                                if let coordiRecord = coordiMainVM.coordiRecord.first(where: {$0.year == selectedYear && $0.month == selectedMonth && $0.day == day.day}) {
                                    
                                    if isDatePast(year: coordiRecord.year, month: coordiRecord.month, day: coordiRecord.day) {
                                        
                                        if let satisfaction = coordiRecord.satisfaction {
                            
                                            Image("doneSatisfaction")
                                        } else {
                                            
                                            Image("notDoneSatisfaction")
                                        }
                                        
                                    } else {
                                        
                                        if coordiRecord.clothesList != [] {
                                            Image("doneSatisfaction")
                                        }
                                    }
                                    
                                    
                                }
                                
                            }
                            
                            Text("\(day.day)")
                                .font(self.selectedDays == day.day ? Font.pretendard(.semibold, size: 20) : Font.pretendard(.semibold, size: 17))
                                .foregroundStyle(self.selectedDays == day.day ? .black : .darkGray)
                                .id(day.day)
                                .onTapGesture {
                                    withAnimation {
                                        self.selectedDays = day.day
                                        value.scrollTo(day.day, anchor: .center)
                                    }
                                }
                            
                            Text("\(day.weekday)")
                                .font(Font.pretendard(.regular, size: 13))
                                .foregroundStyle(self.selectedDays == day.day ? .white : .darkGray)

                            if selectedDays == day.day {
                                
                                if let coordiRecord = coordiMainVM.coordiRecord.first(where: {$0.year == selectedYear && $0.month == selectedMonth && $0.day == day.day}) {
                                    
                                    if let departTime = coordiRecord.departTime, let arrivalTime = coordiRecord.arrivalTime {
                                        
                                        Text("\(DateFormatter.timeString(epoch: departTime)) ~ \(DateFormatter.timeString(epoch: arrivalTime))")
                                            .foregroundStyle(.white)
                                            .font(Font.pretendard(.medium, size: screenWidth / 50))
                                    }
                                }
                            }
                        }
                        .frame(width: screenWidth / 6.75, height: screenHeight / 10)
                        .background(self.selectedDays == day.day ? .mainLight : .white)
                        .cornerRadius(15)
                        .overlay {
                            
                            if selectedDays == day.day {
                                if let coordiRecord = coordiMainVM.coordiRecord.first(where: {$0.year == selectedYear && $0.month == selectedMonth && $0.day == day.day}) {
                                    
                                    if let weather = coordiRecord.weather {
                                        
                                        Circle()
                                            .frame(width: screenWidth / 15, height: screenHeight / 15)
                                            .foregroundStyle(.white)
                                            .overlay {
                                                weather.imageMain
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                    .frame(width: 15, height: 15)
                                            }
                                            .clipShape(Circle())
                                            .overlay {
                                                Circle().stroke(.main, lineWidth: 1)
                                            }
                                            .offset(x: -(screenWidth / 15), y: -(screenHeight / 25))
                                    }
                                    
                                    if let lowestTemp = coordiRecord.lowestTemp, let highestTemp = coordiRecord.highestTemp {
                                        
                                        HStack(spacing: 3) {
                                            
                                            Text("\(lowestTemp)°C")
                                                .font(Font.pretendard(.semibold, size: 10))
                                                .foregroundStyle(.blue)
                                            
                                            Text("/")
                                                .font(Font.pretendard(.regular, size: 10))
                                            
                                            Text("\(highestTemp)°C")
                                                .font(Font.pretendard(.semibold, size: 10))
                                                .foregroundStyle(.red)
                                        }
                                        .frame(width: 60)
                                        .offset(y: screenHeight / 16)
                                        
                                    }
                                }
                            }
                        }
                    }
                }
                .padding()
                .onAppear {
                    value.scrollTo(selectedDays, anchor: .center)
                }
            }
        }
        
    }
    
    private func updateSelection(geo: GeometryProxy, fullView: GeometryProxy, item: Int) {
        let midPoint = geo.frame(in: .global).midX
        if abs(midPoint - fullView.size.width / 2) < 20 { // Threshold to reduce sensitivity
            DispatchQueue.main.async {
                self.selectedDays = item
            }
        }
    }
    
    func changeDays() {
        
        var newDays: [(day: Int, weekday: String)] = []
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                
                if let date = dateFormatter.date(from: "\(selectedYear)-\(selectedMonth)-01") {
                    var dateIter = date
                    let calendar = Calendar.current
                    repeat {
                        let day = calendar.component(.day, from: dateIter)
                        let weekday = calendar.component(.weekday, from: dateIter)
                        newDays.append((day, weekdayString(from: weekday)))
                        
                        dateIter = calendar.date(byAdding: .day, value: 1, to: dateIter)!
                    } while calendar.component(.month, from: dateIter) == selectedMonth
                }
                
                days = newDays
    }
    
    func weekdayString(from number: Int) -> String {
            switch number {
            case 1:
                return "Sun"
            case 2:
                return "Mon"
            case 3:
                return "Tue"
            case 4:
                return "Wed"
            case 5:
                return "Thu"
            case 6:
                return "Fri"
            case 7:
                return "Sat"
            default:
                return "N/A"
            }
        }
    
    func isDatePast(year: Int, month: Int, day: Int) -> Bool {
        let calendar = Calendar.current
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = day

        guard let date = calendar.date(from: dateComponents) else {
            print("Invalid date")
            return false
        }

        let now = Date()
        let makePast = -24 * 60 * 60
        let today = now.addingTimeInterval(TimeInterval(makePast))

        return date < today
    }
}

#Preview {
    CoordiMainView()
}

