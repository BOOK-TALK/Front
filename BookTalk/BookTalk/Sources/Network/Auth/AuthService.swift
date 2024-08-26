//
//  AuthService.swift
//  BookTalk
//
//  Created by 김민 on 8/23/24.
//

import Foundation

struct AuthService {

    static func loginWithkakao(idToken: String) async throws -> Bool {
        let params: LoginRequestDTO = .init(idToken: idToken)

        let result: LoginResponseDTO = try await NetworkService.shared.request(
            target: AuthTarget.loginWithKakao(params: params)
        )

        KeychainManager.shared.saveTokens(
            accessToken: result.accessToken,
            refreshToken: result.refreshToken
        )

        return result.isNewUser
    }

    static func loginWithApple(idToken: String) async throws -> Bool {
        let params: LoginRequestDTO = .init(idToken: idToken)

        let result: LoginResponseDTO = try await NetworkService.shared.request(
            target: AuthTarget.loginWithApple(params: params)
        )

        KeychainManager.shared.saveTokens(
            accessToken: result.accessToken,
            refreshToken: result.refreshToken
        )

        return result.isNewUser
    }

    static func logout() async throws {
        let _ : String = try await NetworkService.shared.request(
            target: AuthTarget.logout
        )

        KeychainManager.shared.deleteTokens()
    }

    static func withdraw() async throws {
        let _ : String = try await NetworkService.shared.request(
            target: AuthTarget.withdraw
        )

        KeychainManager.shared.deleteTokens()
    }

    static func reissueToken(with refreshToken: String) async throws {
        let params: ReissueTokenRequestDTO = .init(refreshToken: refreshToken)

        let newTokens: TokenResponseDTO = try await NetworkService.shared.request(
            target: AuthTarget.reissueToken(params: params)
        )

        KeychainManager.shared.saveTokens(
            accessToken: newTokens.accessToken,
            refreshToken: newTokens.refreshToken
        )
    }
}
