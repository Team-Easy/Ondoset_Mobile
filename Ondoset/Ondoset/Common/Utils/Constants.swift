//
//  Constants.swift
//  Ondoset
//
//  Created by KoSungmin on 4/7/24.
//


/// 공통적으로 쓰이는 상수를 정의해놓은 파일입니다.

import UIKit


struct Constants {
    
    static let successResponseCode: String = "common_2000"
    static var serverURL = isAvailableUnivURL ? univURL : ec2URL
}

// 학과서버 죽으면 false, 쓸 수 있으면 true
let isAvailableUnivURL: Bool = false

let univURL = "http://ceprj.gachon.ac.kr:60019"
let ec2URL = "http://ec2-43-201-46-189.ap-northeast-2.compute.amazonaws.com:8080"


let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
let screenWidth = windowScene?.screen.bounds.width ?? 0
let screenHeight = windowScene?.screen.bounds.height ?? 0

let tabBarHeight = screenHeight / 9
