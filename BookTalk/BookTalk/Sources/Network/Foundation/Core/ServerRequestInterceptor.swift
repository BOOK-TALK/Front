//
//  RequestInterceptor.swift
//  BookTalk
//
//  Created by 김민 on 8/15/24.
//

import Foundation

import Alamofire

final class ServerRequestInterceptor: RequestInterceptor {

    /// request 전 추가 기능
    ///
    /// - Note:
    ///     - access token, refresh token 존재 여부 체크
    ///     - 체크 후에 request header에 추가
    func adapt(
        _ urlRequest: URLRequest,
        for session: Session,
        completion: @escaping (Result<URLRequest, any Error>
        ) -> Void) {
        guard let accessToken = KeychainManager.shared.read(key: TokenKey.accessToken),
              let _ = KeychainManager.shared.read(key: TokenKey.refreshToken) else {
            debugPrint("토큰 없음")
            completion(.success(urlRequest))
            return
        }

        var adaptedRequest = urlRequest
        adaptedRequest.headers.add(.authorization(bearerToken: accessToken))

        completion(.success(adaptedRequest))
    }

    /// request 실패 후 재시도
    func retry(
        _ request: Request,
        for session: Session,
        dueTo error: any Error,
        completion: @escaping (RetryResult) -> Void
    ) {
        // 토큰 재발급이 필요한 statusCode: 401
        guard let response = request.task?.response as? HTTPURLResponse,
              response.statusCode == 401 else {
            completion(.doNotRetryWithError(error))
            return
        }

        guard let _ = KeychainManager.shared.read(key: TokenKey.accessToken),
              let refreshToken = KeychainManager.shared.read(key: TokenKey.refreshToken) else {
            completion(.doNotRetryWithError(error))
            return
        }

        Task {
            do {
                // 토큰 재발급 api 호출, 성공 시 키체인에 새 토큰들 저장
                try await AuthService.reissueToken(with: refreshToken)

                completion(.retry)
                
            } catch let error as NetworkError {
                print(error.localizedDescription)

                completion(.doNotRetryWithError(error))
                
                // 토큰 재발급 불가 시, 로그아웃 처리
                UserDefaults.standard.set(false, forKey: UserDefaults.Key.isLoggedIn)
                NotificationCenter.default.post(name: .authStateChanged, object: nil)
            }
        }
    }
}
