//
//  MyPageMainView.swift
//  Ondoset
//
//  Created by KoSungmin on 4/7/24.
//

import SwiftUI
import Kingfisher

struct MyPageMainView: View {
    
    @StateObject var myPageVM: MyPageMainViewModel = .init()
    @EnvironmentObject var wholeVM: WholeViewModel
    
    let columns: [GridItem] = Array(repeating: .init(.fixed(screenWidth/2), spacing: 1), count: 2)
    
    var body: some View {
        
        NavigationStack {
            
            VStack {
                
                HStack {
                    
                    Spacer()
                
                    /// 설정 화면으로 이동
                    NavigationLink(destination: SettingView(myPageVM: myPageVM)) {
                        Image("setting")
                            .padding(.trailing, 16)
                    } // NavigationLink
                } // HStack
                .frame(height: 30)
                .overlay {
                    Text(myPageVM.memberProfile?.username ?? "사용자 아이디")
                        .font(Font.pretendard(.bold, size: 18))
                }
                
                ScrollView(showsIndicators: false) {
                    
                    VStack(spacing: 0) {
                        
                        HStack {
                            
                            if let imageURL = myPageVM.memberProfile?.profileImage, let url = URL(string: imageURL) {
                                KFImage(url)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 96, height: 96)
                                    .clipShape(Circle())
                                    .overlay {
                                        Circle().stroke(.main, lineWidth: 0.5)
                                    }
                                    .padding(.leading, 35)
                                
                            } else {
                                
                                Image("basicProfileIcon")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 96, height: 96)
                                    .clipShape(Circle())
                                    .overlay {
                                        Circle().stroke(.darkGray, lineWidth: 1)
                                    }
                                    .padding(.leading, 35)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .leading) {
                                
                                HStack {
                                    
                                    Text("게시한 OOTD")
                                        .font(Font.pretendard(.regular, size: 15))
                                    
                                    Text("\(myPageVM.memberProfile?.ootdCount ?? 0)")
                                        .font(Font.pretendard(.bold, size: 17))
                                        .padding(.leading, 24)
                                }
                                
                                NavigationLink(destination: LikeOOTDView()) {
                                    
                                    HStack {
                                        
                                        Text("공감한 OOTD")
                                            .font(Font.pretendard(.regular, size: 15))
                                            .foregroundStyle(.black)
                                        
                                        Text("\(myPageVM.memberProfile?.likeCount ?? 0)")
                                            .font(Font.pretendard(.bold, size: 17))
                                            .padding(.leading, 24)
                                            .foregroundStyle(.black)
                                        
                                        Image("rightChevron2")
                                    }
                                }
                                
                                NavigationLink(destination: FollowingListView()) {
                                    
                                    HStack {
                                        
                                        Text("팔로우한 계정")
                                            .font(Font.pretendard(.regular, size: 15))
                                            .foregroundStyle(.black)
                                        
                                        Text("\(myPageVM.memberProfile?.followingCount ?? 0)")
                                            .font(Font.pretendard(.bold, size: 17))
                                            .padding(.leading, 26)
                                            .foregroundStyle(.black)
                                        
                                        Image("rightChevron2")
                                    }
                                }
                            }
                            
                            Spacer()
                        
                        } // HStack
                        .frame(width: screenWidth, height: 120)
                        .overlay(alignment: .bottom) {
                            Rectangle()
                                .frame(height: 2)
                                .foregroundStyle(.lightGray)
                            
                        }
                        
                        if myPageVM.myOOTDList != [] {
                            
                            LazyVGrid(columns: columns, spacing: 1) {
                                
                                ForEach(myPageVM.myOOTDList.indices, id: \.self) { index in
                                    
                                    let dateString = DateFormatter.string(epoch: myPageVM.myOOTDList[index].date)
                                    
                                    NavigationLink(destination: OOTDItemView(ootdId: myPageVM.myOOTDList[index].ootdId, ootdImageURL: myPageVM.myOOTDList[index].imageURL, dateString: dateString, lowestTemp: myPageVM.myOOTDList[index].lowestTemp, highestTemp: myPageVM.myOOTDList[index].highestTemp)) {
                                        OOTDComponent(date: dateString, minTemp: myPageVM.myOOTDList[index].lowestTemp, maxTemp: myPageVM.myOOTDList[index].highestTemp, ootdImageURL: myPageVM.myOOTDList[index].imageURL)
                                            .frame(width: screenWidth/2)
                                    }
                                    .onAppear {
                                        
                                        ///
                                        if index == myPageVM.myOOTDList.count - 1 {
                                            Task {
                                                await myPageVM.pagingMyProfileOOTD()
                                            }
                                        }
                                    }
                                }
                            }
                            
                        } else {
                            /// OOTD가 없을 경우
                            BlankDataIndicateComponent(explainText: "조회된 OOTD가 없어요")
                                .offset(y: 150)
                        }
                        
//                        if let myOotdList = myPageVM.myOOTDList {
//                            
//                            if myOotdList != [] {
//                                
//                                LazyVGrid(columns: columns, spacing: 1) {
//                                    
//                                    ForEach(myOotdList.indices, id: \.self) { index in
//                                        
//                                        let dateString = DateFormatter.string(epoch: myOotdList[index].date)
//                                        
//                                        NavigationLink(destination: OOTDItemView(ootdId: myOotdList[index].ootdId, ootdImageURL: myOotdList[index].imageURL, dateString: dateString, lowestTemp: myOotdList[index].lowestTemp, highestTemp: myOotdList[index].highestTemp)) {
//                                            OOTDComponent(date: dateString, minTemp: myOotdList[index].lowestTemp, maxTemp: myOotdList[index].highestTemp, ootdImageURL: myOotdList[index].imageURL)
//                                                .frame(width: screenWidth/2)
//                                        }
//                                        .onAppear {
//                                            
//                                            /// 
//                                            if index == myOotdList.count - 1 {
//                                                Task {
//                                                    await myPageVM.pagingMyProfileOOTD()
//                                                }
//                                            }
//                                        }
//                                    }
//                                }
//                                
//                            } else {
//                                /// OOTD가 없을 경우
//                                BlankDataIndicateComponent(explainText: "조회된 OOTD가 없어요")
//                                    .offset(y: 150)
//                            }
//                        }
                    }
                } // ScrollView
                /// 새로고침
                .refreshable {
                    Task {
                        await myPageVM.readMyProfile()
                    }
                }
                .padding(.bottom, tabBarHeight)
            }
            .onAppear {
                wholeVM.isTabBarHidden = false
                
                Task {
                    await myPageVM.readMyProfile()
                }
            }
            .ignoresSafeArea(edges: .bottom)
        }
        
    }
}

#Preview {
    MyPageMainView()
}
