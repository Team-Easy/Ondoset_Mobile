//
//  SignUpFirstView.swift
//  Ondoset
//
//  Created by KoSungmin on 4/19/24.
//

import SwiftUI

struct SignUpFirstView: View {
    
    @Binding var path: NavigationPath
    
    @StateObject var signUpVM: SignUpViewModel = .init()
    
    var body: some View {
        
        VStack(spacing: 0) {
            
            VStack(alignment: .leading, spacing: 0) {
                
                HStack(spacing: 0) {
                    TextFieldComponent(width: 250, placeholder: "아이디", inputText: $signUpVM.idInputText)
                        .onChange(of: signUpVM.idInputText) { id in
                            
                            signUpVM.idConditionCheck(id: id)
                        }
                    
                    ButtonComponent(isBtnAvailable: $signUpVM.isIdCheckBtnAvailable, width: 80, btnText: "중복 확인", radius: 8) {
                        
                        Task {
                            
                            // 아이디 중복 확인 API
                        
                            await signUpVM.checkDuplicateId()
                        }
                    }
                    .padding(.leading, 10)
                }
                
                Text(signUpVM.idPhrase)
                    .font(Font.pretendard(.semibold, size: 10))
                    .padding(.top, 12)
                    .padding(.leading, 15)
                    .foregroundStyle(signUpVM.isIdAvailable ? .blue : .black)
            }
            .padding(.top, 90)
            .onChange(of: signUpVM.isIdAvailable) { _ in
                
                signUpVM.idPhrase = (signUpVM.isIdAvailable ? "사용 가능한 아이디입니다." : "중복된 아이디입니다. 다른 아이디를 입력해주세요.")
                
                signUpVM.updateBtnStatus()
                signUpVM.signUpBtnStatus()
            }
            
            VStack(alignment: .leading, spacing: 0) {
                
                SecureFieldComponent(width: screenWidth - 50, placeholder: "비밀번호", inputText: $signUpVM.pwInputText)
                    .onChange(of: signUpVM.pwInputText) { pw in
                        
                        signUpVM.pwConditionCheck(pw: pw)
                    }
                
                Text(signUpVM.pwPhrase)
                    .font(Font.pretendard(.semibold, size: 10))
                    .padding(.top, 12)
                    .padding(.leading, 15)
                    .foregroundStyle(signUpVM.isPwAvailable ? .blue : .black)
            }
            .padding(.top, 55)
            
            VStack(alignment: .leading, spacing: 0) {
                
                SecureFieldComponent(width: screenWidth - 50, placeholder: "비밀번호 확인", inputText: $signUpVM.pwCheckInputText)
                    .padding(.top, 20)
                    .onChange(of: signUpVM.pwCheckInputText) { _ in
                        
                        if signUpVM.pwInputText == signUpVM.pwCheckInputText {
                            
                            signUpVM.isPwCheckCorrespond = true
                        } else {
                            signUpVM.isPwCheckCorrespond = false
                        }
                        
                        signUpVM.pwCheckPhrase = (signUpVM.isPwCheckCorrespond ? "비밀번호가 일치합니다." : "비밀번호가 일치하지 않습니다.")
                        
                        signUpVM.updateBtnStatus()
                        signUpVM.signUpBtnStatus()
                    }
                
                Text(signUpVM.pwCheckPhrase)
                    .font(Font.pretendard(.semibold, size: 10))
                    .padding(.top, 12)
                    .padding(.leading, 15)
                    .foregroundStyle(signUpVM.isPwCheckCorrespond ? .blue : .black)
                
            }
            .padding(.bottom, 30)
            
            NavigationLink(destination: SignUpSecondView(path: $path, signUpVM: signUpVM)) {
                
                Rectangle()
                    .foregroundStyle(signUpVM.isNextBtnAvailable ? .main : .lightGray)
                    .frame(width: screenWidth - 50, height: 50)
                    .cornerRadius(15)
                    .overlay(
                        Text("다음으로")
                            .font(Font.pretendard(.bold, size: 17))
                            .foregroundStyle(signUpVM.isNextBtnAvailable ? .white : .darkGray)
                    )
            }
            .disabled(!signUpVM.isNextBtnAvailable)
            
            Spacer()
        }
        .navigationTitle("회원 가입")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {

                Button {
                    path.removeLast()
                } label: {
                    Image("leftChevron")
                }
            }
        }
    }
}

#Preview {
    SignUpFirstView(path: .constant(NavigationPath()))
}
