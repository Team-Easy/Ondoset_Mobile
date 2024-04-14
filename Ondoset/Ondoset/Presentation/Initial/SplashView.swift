//
//  SplashView.swift
//  Ondoset
//
//  Created by KoSungmin on 4/7/24.
//

import SwiftUI

struct SplashView: View {
    
    @State var isActive: Bool = false   // 다음 화면 활성화
    @AppStorage("isLogin") var isLogin: Bool = false
    @AppStorage("isOnboardingDone") var isOnboardingDone: Bool = false
    
    var body: some View {
        ZStack {
            
            if !isLogin && isActive {
                SignInView()
            } else if isLogin && isActive && isOnboardingDone {
                OndosetHome()
            } else if isLogin && isActive && !isOnboardingDone{
                OnboardingView()
            } else {
                
                ZStack {
                    Color(.main)
                    VStack {
                        Image("whiteAppIcon")
                        Text("ondoset")
                            .font(Font.pretendard(.bold, size: 50))
                            .foregroundStyle(.white)
                    }
                }
            }
        }
        .onAppear {
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                isActive = true
            }
        }
        .ignoresSafeArea()
    }
}

#Preview {
    SplashView()
}
