//
//  OOTDItemView.swift
//  Ondoset
//
//  Created by KoSungmin on 4/29/24.
//

import SwiftUI
import Kingfisher

struct OOTDItemView: View {
    
    let ootdId: Int
    let ootdImageURL: String
    let dateString: String
    let lowestTemp: Int
    let highestTemp: Int
    
    let memberId = UserDefaults.standard.integer(forKey: "memberId")
    
    @State var isReportAvailable: Bool = false
    @State var showCantReportAlert: Bool = false
    @State var banPeriod: Int = 0
    
    @State var showReportAlertView: Bool = false
    @State var showWritingReportReassonAlertView: Bool = false
    @State var showDeleteOOTDAlertView: Bool = false
    
    @State var reportReason: String = ""
    
    @StateObject var ootdItemVM: OOTDItemViewModel = .init()
    @EnvironmentObject var wholeVM: WholeViewModel
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        
        ZStack {
            
            ScrollView(showsIndicators: false) {
                
                VStack(spacing: 0) {
                    
                    HStack(spacing: 0) {
                        
                        if let imageURL = ootdItemVM.ootdItem?.imageURL, let url = URL(string: imageURL) {
                            
                            KFImage(url)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: screenWidth / 8)
                                .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                                .overlay {
                                    Circle().stroke(.main, lineWidth: 0.5)
                                }
                            
                        } else {
                            Image("basicProfileIcon")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: screenWidth / 7.8)
                                .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                                .overlay {
                                    Circle().stroke(.main, lineWidth: 0.5)
                                }
                        }
                        
                        NavigationLink(destination: OtherProfileView(nickname: ootdItemVM.ootdItem?.nickname ?? "테스트 타인 닉네임", profileImage: ootdItemVM.ootdItem?.imageURL, memberId: ootdItemVM.ootdItem?.memberId ?? 0, isFollowing: ootdItemVM.ootdItem?.isFollowing ?? false, ootdCount: ootdItemVM.ootdItem?.ootdCount ?? 0)) {
                            Text(ootdItemVM.ootdItem?.nickname ?? "사용자 닉네임")
                                .padding(.leading, 16)
                                .foregroundStyle(.black)
                        }.disabled((memberId == ootdItemVM.ootdItem?.memberId))
                        
                        
                        
                        Spacer()
                        
                        /// 해당 OOTD 게시물이 사용자 본인의 것이 아닌 경우
                        if memberId != ootdItemVM.ootdItem?.memberId {
                            
                            FollowingBtnComponent(isFollowing: $ootdItemVM.isFollowing) {

                                if ootdItemVM.isFollowing {
                                    
                                    Task {
                                        await ootdItemVM.cancelFollowOther()
                                    }
                                    
                                } else {
                                    Task {
                                        await ootdItemVM.followOther()
                                    }
                                }
                            }
                            
                        /// 해당 OOTD 게시물이 사용자 본인의 것인 경우
                        } else {
                            
                            Menu(content: {
                                
                                NavigationLink(destination: PutOOTDView(ootdId: ootdId)) {
                                    Text("OOTD 수정하기")
                                }
                                
                                Button(role: .destructive,
                                       action: {
                                    
                                    showDeleteOOTDAlertView = true

                                }) {
                                    Text("OOTD 삭제하기")
                                }
                            }, label: {
                                Image(systemName: "ellipsis")
                                    .frame(width:24, height: 24)
                                    .rotationEffect(.degrees(90))
                                    .foregroundColor(.gray)
                                    .clipShape(Circle())
                            })
                        }
                        
                    } // HStack
                    .padding(.horizontal, 24)
                    .padding(.bottom, 13)
                    
                    /// OOTD 게시물 이미지
                    KFImage(URL(string: ootdImageURL))
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: screenWidth)
                        
                    HStack(spacing: 8) {
                        
                        Text("\(dateString)")
                            .font(Font.pretendard(.medium, size: 13))
                            .foregroundStyle(.darkGray)
                        
                        if let weatherString = ootdItemVM.ootdItem?.weather, let weather = Weather(rawValue: weatherString) {
                            
                            weather.imageMain
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 20, height: 20)
                            
                        }
                        
                        HStack(spacing: 0) {
                            Text("\(lowestTemp)°C")
                                .font(Font.pretendard(.semibold, size: 13))
                                .foregroundStyle(.min)
                            
                            Text(" / ")
                                .font(Font.pretendard(.semibold, size: 13))
                                
                            Text("\(highestTemp)°C")
                                .font(Font.pretendard(.semibold, size: 13))
                                .foregroundStyle(.max)
                        } // HStack
                        
                        Spacer()
                        
                        if memberId != ootdItemVM.ootdItem?.memberId {
                            
                            if ootdItemVM.ootdItem?.isLike == true {
                                
                                Image("ootdLikeFill")
                                    .onTapGesture {
                                        Task {
                                            await ootdItemVM.cancelLikeOOTD(ootdId: ootdId)
                                        }
                                    }
                                
                            } else {
                                
                                Image("ootdLike")
                                    .onTapGesture {
                                        Task {
                                            await ootdItemVM.likeOOTD(ootdId: ootdId)
                                        }
                                    }
                            }
                        }
                    } // HStack
                    .padding(.vertical, 12)
                    .padding(.horizontal, 24)
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]) {
                        
                        ForEach(ootdItemVM.ootdItem?.wearing ?? [], id: \.self) { cloth in
                            
                            Text("# \(cloth)")
                                .font(Font.pretendard(.semibold, size: 13))
                            
                        }
                    }
                    .padding(.horizontal, 15)
                    
                    Spacer()

                } // VStack
            } // ScrollView
                
            if showReportAlertView {
                
                ExtendedAlertComponent(showAlert: $showReportAlertView, isTabBarExist: false, alertTitle: "OOTD 신고", content: AnyView(Text("아래 사유로 신고하시겠습니까? \n사유: 코디 사진이 아니에요")), rightBtnTitle: "확인", rightBtnAction: {
                    
                    Task {
                        
                        let result = await ootdItemVM.reportOOTD(ootdId: ootdId, reason: "코디 사진이 아니에요")
                        
                        showReportAlertView = false
                    }
                    
                })
                
                
            } else if showWritingReportReassonAlertView {
                
                ExtendedAlertComponent(showAlert: $showWritingReportReassonAlertView, isTabBarExist: false, alertTitle: "OOTD 신고", content: AnyView(
                    
                    VStack(spacing: 15) {
                        
                        Text("신고 사유를 입력해주세요")
                        
                        TextField("불건전한 컨텐츠", text: $reportReason)
                            .font(.pretendard(.semibold, size: 15))
                            .padding(.leading, 10)
                        
                    }
                    
                ), rightBtnTitle: "확인", rightBtnAction: {
                    
                    Task {
                        
                        let result = await ootdItemVM.reportOOTD(ootdId: ootdId, reason: reportReason)
                        
                        showWritingReportReassonAlertView = false
                        
                        reportReason = ""
                    }
                })
            }
            
            if showCantReportAlert {

                ExtendedAlertComponent(showAlert: $showCantReportAlert, isTabBarExist: false, alertTitle: "신고할 수 없습니다.", content: AnyView(Text("사용자님의 활동에 문제가 감지되어 \n다음 기간동안 활동이 제한됩니다. \n기간: \(banPeriod)일")), rightBtnTitle: "확인", rightBtnAction: {
                    showCantReportAlert = false
                })
                
            }
            
            if showDeleteOOTDAlertView {
                
                ExtendedAlertComponent(showAlert: $showDeleteOOTDAlertView, isTabBarExist: false, alertTitle: "OOTD 삭제", content: AnyView(Text("삭제하면 취소할 수 없습니다. \n정말로 삭제하시겠습니까?")), rightBtnTitle: "확인", rightBtnAction: {
                    
                    Task {
                     
                        // OOTD삭제 API 호출
                        let result = await ootdItemVM.deleteOOTD(ootdId: ootdId)
                        
                        if result {
                            dismiss()
                        }
                    }
                })

            }
            
        } // ZStack
        .onAppear {
            
            Task {
                await ootdItemVM.getOOTDItem(ootdId: ootdId)
            }
            
            wholeVM.isTabBarHidden = true

            Task {
                
                let result = await ootdItemVM.getBanPeriod()
                
                banPeriod = result
                
                if result <= 0 {
                    
                    isReportAvailable = true
                    
                } else {
                    isReportAvailable = false
                }
            }
        }
        .navigationTitle("OOTD")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {

                Button {
                    
                    dismiss()
                    
                } label: {
                    Image("leftChevron")
                }
            }
        }
        .toolbar {
            
            ToolbarItem(placement: .topBarTrailing) {
             
                if memberId != ootdItemVM.ootdItem?.memberId {
                    
                    if isReportAvailable {
                        
                        Menu(content: {
                        
                            Button {
    
                                showReportAlertView = true
    
                            } label: {
                                Text("코디 사진이 아니에요")
                            }
    
                            Button {
    
                                showWritingReportReassonAlertView = true
                                
                            } label: {
                                Text("직접 작성")
                            }
    
    
                        }, label: {
    
                            Image("ootdReport")
                                .frame(width:24, height: 24)
                                .foregroundColor(.gray)
                                .clipShape(Circle())
                        })
                        
                    } else {
                        
                        Button {
                            
                            showCantReportAlert = true
                            
                        } label: {
                            
                            Image("ootdReport")
                                .frame(width:24, height: 24)
                                .foregroundColor(.gray)
                                .clipShape(Circle())
                            
                        }
                    }
                }
            }
        }
    }
    
    var content: some View {
        
        VStack {
            
            Text("신고 사유를 입력해주세요")
            
            TextField("ex) 부적절한 컨텐츠", text: $reportReason)
                .font(.pretendard(.semibold, size: 15))
                .padding(.leading, 10)
            
        }
    }
}

#Preview {
    OOTDItemView(ootdId: 0, ootdImageURL: "", dateString: "2024", lowestTemp: 4, highestTemp: 15)
}
