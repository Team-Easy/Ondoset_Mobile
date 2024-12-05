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
    static var serverURL = isDevelopURL ? developURL : ec2URL
}

let isDevelopURL: Bool = false

// 개발용
let developURL = "http://ec2-43-201-46-189.ap-northeast-2.compute.amazonaws.com:8080/member/test"
//let ec2URL = "http://ec2-43-201-46-189.ap-northeast-2.compute.amazonaws.com:8080"
/// 운영용
let ec2URL = "https://ondoset.shop"


let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
let screenWidth = windowScene?.screen.bounds.width ?? 0
let screenHeight = windowScene?.screen.bounds.height ?? 0

let tabBarHeight = screenHeight / 9
