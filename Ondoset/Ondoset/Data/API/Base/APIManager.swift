//
//  APIManager.swift
//  Ondoset
//
//  Created by KoSungmin on 4/8/24.
//

import Foundation
import Alamofire

enum APIError: Error {
    case authenticationRetryNeeded
}

final class APIManager {
    
    static let shared = APIManager()
    
    private init () {}
    
    // MARK: Repository에서 호출하는 메소드
    func performRequest<T: Decodable>(endPoint: EndPoint, decoder: DataDecoder = JSONDecoder()) async -> T? {
        
        var result: Data = .init()
        
        do {
            let request = await self.requestData(endPoint: endPoint)
            result = try request.result.get()
        } catch {
            print("====네트워크 에러====")
            print("\(String(data: result, encoding: .utf8))")
            return nil
        }
        
        do {
            let decodedData = try result.decode(type: BaseResponse<T>.self, decoder: decoder)
            return decodedData.result
        } catch {
            print("====디코딩 에러====")
            print("\(String(data: result, encoding: .utf8))")
            return nil
        }
    }
    
    // 요청 메소드
    func requestData(endPoint: EndPoint) async -> DataResponse<Data, AFError> {
                 
        var response = await makeDataRequest(endPoint: endPoint).serializingData().response
        
        // HTTP Status가 401일 때(토큰이 만료되었을 때)
        if let statusCode = response.response?.statusCode, statusCode == 401 {


            guard await ReissuanceToken() else {
                
                // 토큰 갱신에 실패한 경우
                
                print("==== 토큰 갱신 실패로 로그아웃 처리됨 ====")

                // 로그아웃 처리
                DispatchQueue.main.async {
                    UserDefaults.standard.set(false, forKey: "isLogin")
                }
                return response
            }
            
            // 토큰 갱신에 성공한 경우
            // 원래 요청을 다시 시도
            response = await makeDataRequest(endPoint: endPoint).serializingData().response
        }
        return response
    }
    
    // 토큰 재발급 메소드
    private func ReissuanceToken() async -> Bool {
        
        guard let accessToken = KeyChainManager.readItem(key: "accessToken"),
              let refreshToken = KeyChainManager.readItem(key: "refreshToken") else {
            
            // 기존에 가지고 있던 토큰 확인 후 토큰이 없는 경우 false를 반환함으로써 requestData() 내부에서 로그아웃 처리로 이어짐
            print("==== 토큰이 없어서 로그아웃 처리됨 ====")
            return false
        }
        
        // 기존에 가지고 있던 토큰이 있는 경우 토큰 재발급 요청을 보냄
        let response = await makeDataRequest(endPoint: MemberEndPoint.reissuanceToken(tokenReissuanceRequestDTO: TokenReissuanceRequestDTO(accessToken: accessToken, refreshToken: refreshToken))).serializingData().response
        
        // 토큰 재발급 응답이 401일 경우 == RefreshToken도 만료되었을 경우
        if response.response?.statusCode == 401 {
            
            print("====토큰 갱신 실패로 로그아웃 처리됨(APIManager)====")

            // 로그아웃 처리
            DispatchQueue.main.async {
                UserDefaults.standard.set(false, forKey: "isLogin")
            }
            return false
        }
        
        // 토큰 재발급이 정상적으로 이루어졌을 경우
        
        print("리프래시 토큰으로 액세스 토큰 재발급")
        print("리프래시 토큰도 재발급됨.")
        
        var result: Data = .init()
        
        do {
            result = try response.result.get()
            
            // 새롭게 발급받은 토큰을 키체인에 저장
            let decodedData = try result.decode(type: BaseResponse<TokenReissuanceResponseDTO>.self, decoder: JSONDecoder())
            KeyChainManager.addItem(key: "accessToken", value: decodedData.result.accessToken)
            KeyChainManager.addItem(key: "refreshToken", value: decodedData.result.refreshToken)
            
        } catch {
            
            print("토큰 재발급 후 저장 과정에서 에러!")
        }
        
        return true
    }
}

extension APIManager {
    
    /// Endpoint의 task에 따라 요청 데이터 생성
    private func makeDataRequest(endPoint: EndPoint) -> DataRequest {
        
        switch endPoint.task {
            
        // 요청 데이터 없는 단순한 요청
        case .requestPlain:
            return AF.request(
                "\(endPoint.baseURL)\(endPoint.path)",
                method: endPoint.method,
                headers: endPoint.headers,
                interceptor: AuthManager()
            )
            
        // RequestBody에 JSON 데이터로 요청
        case let .requestJson(parameters):
            return AF.request(
                "\(endPoint.baseURL)\(endPoint.path)",
                method: endPoint.method,
                parameters: parameters,
                encoder: JSONParameterEncoder.default,
                headers: endPoint.headers,
                interceptor: AuthManager()
            )
            
        // RequestBody에 JSON 데이터로 요청(토큰X)
        case let .requestJsonWithoutToken(parameters):
            return AF.request(
                "\(endPoint.baseURL)\(endPoint.path)",
                method: endPoint.method,
                parameters: parameters,
                encoder: JSONParameterEncoder.default,
                headers: endPoint.headers
            )
            
        // 쿼리 파라미터 요청
        case let .requestQueryParams(parameters, encoding):
            return AF.request(
                "\(endPoint.baseURL)\(endPoint.path)",
                method: endPoint.method,
                parameters: parameters,
                encoding: encoding,
                headers: endPoint.headers,
                interceptor: AuthManager()
            )
            
        // 쿼리 파라미터 요청(토큰X)
        case let .requestQueryParamsWithoutToken(parameters, encoding):
            return AF.request(
                "\(endPoint.baseURL)\(endPoint.path)",
                method: endPoint.method,
                parameters: parameters,
                encoding: encoding,
                headers: endPoint.headers
            )
            
        // PathVariable 요청
        case .requestPathVariable:
            return AF.request(
                "\(endPoint.baseURL)\(endPoint.path)",
                method: endPoint.method,
                headers: endPoint.headers,
                interceptor: AuthManager()
            )
            
        // form 데이터로 이미지 전송
        case let .uploadImage(image):
            return AF.upload(multipartFormData: { multipartFormData in
                
                multipartFormData.append(image, withName: "image", fileName: "\(image).jpeg", mimeType: "image/jpeg")
            }, to: URL(string: "\(endPoint.baseURL)\(endPoint.path)")!, method: endPoint.method, headers: endPoint.headers, interceptor: AuthManager())
            
        // form 데이터 요청
        case let .uploadImagesWithData(image, body):
            
            if let image = image {
                return AF.upload(multipartFormData: { multipartFormData in
                    
                    multipartFormData.append(image, withName: "image", fileName: "\(image).jpeg", mimeType: "image/jpeg")
                    
                    for (key, value) in body {
                        if let data = String(describing: value).data(using: .utf8) {
                            multipartFormData.append(data, withName: key)
                        }
                    }
                }, to: URL(string: "\(endPoint.baseURL)\(endPoint.path)")!, method: endPoint.method, headers: endPoint.headers, interceptor: AuthManager())
            } else {
                
                return AF.upload(multipartFormData: { multipartFormData in
                    
                    for (key, value) in body {
                        if let data = String(describing: value).data(using: .utf8) {
                            multipartFormData.append(data, withName: key)
                        }
                    }
                }, to: URL(string: "\(endPoint.baseURL)\(endPoint.path)")!, method: endPoint.method, headers: endPoint.headers, interceptor: AuthManager())
            }
        }
    }
}
