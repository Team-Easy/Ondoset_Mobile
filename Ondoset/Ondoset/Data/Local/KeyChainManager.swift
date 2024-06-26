//
//  KeyChainManager.swift
//  Ondoset
//
//  Created by KoSungmin on 4/8/24.
//


/// JWT 토큰과 같은 값들을 로컬에 저장하기 위한 키체인 매니저 정의 파일입니다.

import Foundation

class KeyChainManager {
    
    static let service = Bundle.main.bundleIdentifier
    
    // MARK: 키체인에 아이템 저장
    static func addItem(key: String, value: String) {
        
        let valueData = value.data(using: .utf8)!
        
        let query: [CFString: Any] = [kSecClass: kSecClassGenericPassword,
                                kSecAttrService: service ?? "com.easy.Ondoset",
                                kSecAttrAccount: key,
                                  kSecValueData: valueData]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        if status == errSecSuccess {
            print("키체인에 아이템 저장 성공")
            print("\(key): \(valueData)")
        } else if status == errSecDuplicateItem {   // key가 중복될 경우 업데이트
            updateItem(key: key, value: value)
        } else {
            print("키체인에 아이템 저장 실패")
        }
    }
    
    // MARK: 키체인 아이템 조회
    static func readItem(key: String) -> String? {
        
        let query: [CFString: Any] = [kSecClass: kSecClassGenericPassword,
                                kSecAttrService: service ?? "com.easy.Ondoset",
                                kSecAttrAccount: key,
                           kSecReturnAttributes: true,
                                 kSecReturnData: true]
        
        var item: CFTypeRef?
        if SecItemCopyMatching(query as CFDictionary, &item) != errSecSuccess {
            print("키체인 아이템 읽기 실패")
            return nil
        }
        
        guard let existItem = item as? [String:Any],
              let data = existItem[kSecValueData as String] as? Data,
              let returnValue = String(data: data, encoding: .utf8) else {
            return nil
        }

        return returnValue
    }
    
    // MARK: 키체인 값 업데이트
    static func updateItem(key: String, value: String) {
        
        let valueData = value.data(using: .utf8)!
        
        let previousQuery: [CFString: Any] = [kSecClass: kSecClassGenericPassword,
                                        kSecAttrService: service ?? "com.easy.Ondoset",
                                        kSecAttrAccount: key]
        
        let updateQuery: [CFString: Any] = [kSecValueData: valueData]
        
        let status = SecItemUpdate(previousQuery as CFDictionary, updateQuery as CFDictionary)
        
        if status == errSecSuccess {
            print("키체인 아이템 업데이트 성공")
        } else {
            print("키체인 아이템 업데이트 실패")
        }
    }
    
    // MARK: 키체인 아이템 삭제
    static func deleteItem(key: String) {
        
        let deleteQuery: [CFString: Any] = [kSecClass: kSecClassGenericPassword,
                                      kSecAttrService: service ?? "com.easy.Ondoset",
                                      kSecAttrAccount: key]
        
        let status = SecItemDelete(deleteQuery as CFDictionary)
        if status == errSecSuccess {
            print("키체인 아이템 삭제 성공")
        } else {
            print("키체인 아이템 삭제 실패")
        }
    }
    
    // MARK: 키체인 아이템 존재 여부 확인
    static func itemExists(key: String) -> Bool {
        
        let query: [CFString: Any] = [kSecClass: kSecClassGenericPassword,
                                kSecAttrService: service ?? "com.easy.Ondoset",
                                kSecAttrAccount: key,
                                 kSecMatchLimit: kSecMatchLimitOne,
                           kSecReturnAttributes: false]
        
        let status = SecItemCopyMatching(query as CFDictionary, nil)
        
        return status == errSecSuccess
    }
}
