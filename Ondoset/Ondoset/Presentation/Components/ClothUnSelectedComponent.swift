//
//  ClothUnSelectedComponent.swift
//  Ondoset
//
//  Created by 박민서 on 5/2/24.
//

import SwiftUI
import Kingfisher

struct ClothUnSelectedComponent: View {
    
    /// 옷 템플릿
    let clothTemplate: ClothTemplate
    
    /// 서치모드
    @Binding var searchMode: Bool
    /// 선택 검색 탭
    @State var selectedTab: Int = 0
    /// 검색 텍스트
    @State var searchText: String = ""
    /// 검색 옷 목록
    @State var clothesList: [Clothes] = []
    
    // 옷 카테고리
//    let category: Category
    // 옷 이름
//    let clothName: String
    // 너비
    let width: CGFloat
    // 우측에 들어가는 내용
    var additionBtn: AnyView? = nil
    
    let test: [Clothes] =  ClothesDTO.mockData()
    
    var body: some View {
        Rectangle()
            .frame(width: width, height: searchMode ? 360 : 80)
            .foregroundStyle(.white)
            .cornerRadius(10)
            .overlay(alignment: .top) {
                
                // 카테고리 존재하는 경우
                if let category = clothTemplate.category {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(category.lightColor)
                    
                    VStack {
                        HStack(spacing: 10) {
                            
                            // 카테고리 이미지
                            category.categoryImage
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 48, height: 48)
                            
                            Rectangle()
                                .foregroundStyle(category.color)
                                .frame(width: 2, height: 36)
                            
                            HStack(alignment: .center) {
                                
                                Text(clothTemplate.name)
                                    .font(Font.pretendard(.semibold, size: 17))
                                Button(action: {
                                    withAnimation {
                                        self.searchMode.toggle()
                                    }
                                }, label: {
                                    Image(systemName: "magnifyingglass")
                                        .foregroundStyle(.black)
                                })
                            }
                            .padding(.leading, 5)
                            
                            Spacer()
                            
                            if let additionalButton = self.additionBtn {
                                additionalButton
                            }
                            
                        }
                        .padding(.leading, 18)
                        
                        if searchMode {
                            // 아이템 목록
                            ScrollView(.vertical) {
                                VStack(spacing: 10) {
                                    ForEach(test.indices, id: \.self) { index in
                                        ClothSelectedComponent(
                                            category: test[index].category,
                                            clothName: test[index].name,
                                            clothTag: test[index].tag,
                                            clothThickness: test[index].thickness ?? .NORMAL,
                                            width: 320
                                        )
                                    }
                                }
                            }
                            .frame(height: 250)
                            HStack {
                                Spacer()
                                Button(action: {
                                    
                                }, label: {
                                    HStack(spacing: 0) {
                                        Text("이 키워드로 쇼핑몰에서 찾아보기")
                                            .font(.pretendard(.semibold, size: 13))
                                        Image(systemName: "chevron.forward")
                                    }
                                    .foregroundStyle(.main)
                                })
                            }
                            .padding(.horizontal)
                            
                        }
                    }
                }
                // 직접 추가하여 검색하는 경우
                else {
                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(Color.gray, style: .init(lineWidth: 2, lineCap: .round, lineJoin: .round, miterLimit: 8, dash: [8], dashPhase: 10))
                    if searchMode {
                        VStack {
                            // 상단 타이틀 + x 버튼
                            HStack {
                                Text("직접 검색하여 추가하기")
                                    .font(.pretendard(.semibold, size: 17))
                                Spacer()
                                Button(action: {
                                    withAnimation {
                                        self.searchMode.toggle()
                                    }
                                }, label: {
                                    Image(systemName: "xmark")
                                        .renderingMode(.template)
                                        .foregroundStyle(.black)
                                        .fontWeight(.semibold)
                                })
                            }
                            .padding(.top)
                            .padding(.horizontal)
                            
                            // 중간 세그먼트 컨트롤
                            SegmentControlComponent(selectedTab: $selectedTab, tabMenus: MyClosetTab.allCases.map{ $0.rawValue }, isMain: false)
                                
                            // 중간 서치바
                            SearchBarComponent(searchText: $searchText, placeHolder: "등록한 옷을 검색하세요", searchAction: { print($0) })
                                .padding(.horizontal)
                            
                            // 아이템 목록
                            ScrollView(.vertical) {
                                VStack(spacing: 10) {
                                    ForEach(test.indices, id: \.self) { index in
                                        ClothSelectedComponent(
                                            category: test[index].category,
                                            clothName: test[index].name,
                                            clothTag: test[index].tag,
                                            clothThickness: test[index].thickness ?? .NORMAL,
                                            width: 300
                                        )
                                        .onTapGesture {
                                            print(test[index])
                                        }
                                    }
                                }
                                .padding()
                            }
                            .frame(height: 180)
                            .padding(.bottom)
                            
                        }
                    } else {
                        Button(action: {
                            withAnimation {
                                self.searchMode.toggle()
                            }
                        }, label: {
                            Text("직접 검색하여 추가하기")
                                .font(.pretendard(.semibold, size: 17))
                                .foregroundStyle(.gray)
                        })
                    }
                }
            }
    }
}

#Preview {
    ClothUnSelectedComponent(
        clothTemplate: .init(name: "바지"), searchMode: .constant(true),
        width: 340,
        additionBtn: AnyView(
            Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                Image(systemName: "xmark")
                    .fontWeight(.semibold)
                    .foregroundStyle(.black)
            })
            .padding()
        )
    )
}
