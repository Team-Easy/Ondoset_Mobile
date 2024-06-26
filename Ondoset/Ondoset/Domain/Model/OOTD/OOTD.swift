//
//  OOTD.swift
//  Ondoset
//
//  Created by KoSungmin on 4/8/24.
//

import Foundation

// OOTD 전체 조회할 때 쓰이는 구조체
struct OOTD: Hashable {
    
    let ootdId: Int
    let date: Int
    let lowestTemp: Int
    let highestTemp: Int
    let imageURL: String
}

// OOTD 개별 조회할 때 쓰이는 구조체
struct OOTDItem: Hashable {
    
    let memberId: Int
    let nickname: String
    let imageURL: String?
    let isFollowing: Bool
    let ootdCount: Int
    let weather: String
    let wearing: [String]
    var isLike: Bool
}

struct MemberProfile: Hashable {
    
    let username: String
    let nickname: String
    let profileImage: String?
    var ootdList: [OOTD]
    let ootdCount: Int
    let likeCount: Int
    let followingCount: Int    
    let lastPage: Int
}

struct PagingOOTD: Hashable {
    
    let lastPage: Int
    let ootdList: [OOTD]
}

struct Following: Hashable {
    
    let memberId: Int
    let nickname: String
    let imageURL: String?
    var isFollowing: Bool
    let ootdCount: Int
}

struct PagingFollowing: Hashable {
    
    let lastPage: Int
    let followingList: [Following]
}

struct OOTDWeather: Hashable {
    
    let lat: Double
    let lon: Double
    let departTime: Int
    let arrivalTime: Int
}


struct AddOOTD: Hashable {
    
    var departTime: String
    var arrivalTime: String
    var weather: String
    var lowestTemp: String
    var highestTemp: String
    var image: Data
    var wearingList: [String]
}

// OOTD 수정용 조회할 때 쓰이는 구조체
struct GetOOTDforPut: Hashable {
    
    let ootdId: Int
    var region: String
    var departTime: Int
    var arrivalTime: Int
    var weather: Weather
    var lowestTemp: Int
    var highestTemp: Int
    var imageURL: String
    var wearingList: [String]
}

// 타인 프로필 조회 및 OOTD 목록 조회 구조체
struct OtherProfile: Hashable {
    
    let lastPage: Int
    let ootdList: [OOTD]
}
