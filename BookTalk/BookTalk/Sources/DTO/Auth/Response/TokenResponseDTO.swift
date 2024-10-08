//
//  TokenResponseDTO.swift
//  BookTalk
//
//  Created by 김민 on 8/25/24.
//

import Foundation

struct TokenResponseDTO: Decodable {
    let accessToken: String
    let refreshToken: String
}

extension TokenResponseDTO {

    func toModel() -> Tokens {
        return .init(
            accessToken: accessToken,
            refreshToken: refreshToken
        )
    }
}
