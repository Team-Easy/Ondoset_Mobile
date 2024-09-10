//
//  SignUpSecondView.swift
//  Ondoset
//
//  Created by KoSungmin on 4/19/24.
//

import SwiftUI

struct SignUpSecondView: View {
    
    @Binding var path: NavigationPath
    
    @ObservedObject var signUpVM: SignUpViewModel
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 0) {
            
            Text("사용하실 닉네임을 알려주세요")
                .font(Font.pretendard(.semibold, size: 17))
            
            HStack {
                
                TextFieldComponent(width: 250, placeholder: "닉네임", inputText: $signUpVM.nicknameInputText)
                    .onChange(of: signUpVM.nicknameInputText) { nickname in
                        
                        if nickname.count > 0 {
                            signUpVM.isNicknameCheckBtnAvailable = true
                        } else {
                            signUpVM.isNicknameCheckBtnAvailable = false
                            signUpVM.nicknamePhrase = ""
                        }
                        
                        signUpVM.signUpBtnStatus()
                    }
        
                ButtonComponent(isBtnAvailable: $signUpVM.isNicknameCheckBtnAvailable, width: 80, btnText: "중복 확인", radius: 8) {
                    
                    Task {
                        await signUpVM.checkDuplicateNickname()
                    }
                }
            }
            .padding(.top, 16)
            
            Text(signUpVM.isNicknameAvailable ? "사용 가능한 닉네임입니다." : "중복된 닉네임입니다. 다른 닉네임을 입력해주세요.")
                .font(Font.pretendard(.semibold, size: 10))
                .padding(.top, 12)
                .padding(.leading, 15)
                .foregroundStyle(signUpVM.isNicknameCheckBtnAvailable ? .blue : .black)
                .hidden(signUpVM.isNicknamePhraseHidden)
            
            ButtonComponent(isBtnAvailable: $signUpVM.isSignUpBtnAvailable, width: screenWidth - 50, btnText: "회원가입", radius: 15) {
                
                Task {
                    
                    await signUpVM.signUpMember()
                    
                    path.removeLast()
                }
            }
            .padding(.top, 80)
            .disabled(!signUpVM.isSignUpBtnAvailable)
            
            Spacer()
        }
        .padding(.top, 70)
        .navigationTitle("회원 가입")
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
    }
}

#Preview {
    SignUpSecondView(path: .constant(NavigationPath()), signUpVM: SignUpViewModel())
}
